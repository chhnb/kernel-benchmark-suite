#pragma once

#include "options.hpp"
#include <hip/hip_runtime.h>
#include <algorithm>
#include <cmath>

inline void hipCheck(hipError_t error) {
    if (error != hipSuccess)
        throw std::runtime_error(hipGetErrorString(error));
}

inline void copyDevice(void *to, const void *from, size_t bytes, hipStream_t stream) {
    hipCheck(hipMemcpyAsync(to, from, bytes, hipMemcpyDeviceToDevice, stream));
}

inline float eventTime(hipEvent_t start, hipEvent_t stop) {
    float ms;
    hipCheck(hipEventElapsedTime(&ms, start, stop));
    return ms;
}

class TimedWindow {
    hipStream_t stream;
    std::vector<hipEvent_t> starts, stops;

    void reserveEvents(int count) {
        while (int(starts.size()) < count) {
            hipEvent_t start, stop;
            hipCheck(hipEventCreate(&start));
            hipCheck(hipEventCreate(&stop));
            starts.push_back(start);
            stops.push_back(stop);
        }
    }
    void sync() { hipCheck(hipStreamSynchronize(stream)); }
    void mark(hipEvent_t event) { hipCheck(hipEventRecord(event, stream)); }

public:
    explicit TimedWindow(hipStream_t stream) : stream(stream) { reserveEvents(1); }
    ~TimedWindow() {
        for (auto event : starts) hipEventDestroy(event);
        for (auto event : stops) hipEventDestroy(event);
    }

    template<typename Reset, typename Launch>
    void warm(Reset reset, Launch launch) {
        reset();
        float total = 0;
        int count = 32;
        while (total < 200) {
            mark(starts[0]);
            for (int i = 0; i < count; ++i) launch();
            mark(stops[0]);
            sync();
            float ms = eventTime(starts[0], stops[0]);
            total += ms;
            count = std::clamp(int(std::ceil((200 - total) * count / std::max(ms, 0.01f))), 1, 4096);
        }
    }

    template<typename Reset, typename Launch, typename Check>
    float single(Reset reset, Launch launch, Check check) {
        reset();
        mark(starts[0]);
        launch();
        mark(stops[0]);
        sync();
        check();
        return eventTime(starts[0], stops[0]);
    }

    template<typename Reset, typename Launch, typename Check>
    float batch(int count, bool restoreBetween, Reset reset, Launch launch, Check check) {
        reset();
        mark(starts[0]);
        for (int i = 0; i < count; ++i) {
            if (i && restoreBetween) reset();
            launch();
        }
        mark(stops[0]);
        sync();
        check();
        return eventTime(starts[0], stops[0]);
    }

    template<typename Reset, typename Launch, typename Capture, typename Check>
    std::vector<float> asynchronous(int count, Reset reset, Launch launch,
                                    Capture capture, Check check) {
        reserveEvents(count);
        int slot = 0;
        for (int i = 0; i < count; ++i) {
            reset();
            mark(starts[i]);
            launch();
            mark(stops[i]);
            if (i == 0 || (i + 1) % 50 == 0 || i + 1 == count)
                capture(slot++);
        }
        sync();
        for (int i = 0; i < slot; ++i) check(i);
        std::vector<float> times(count);
        for (int i = 0; i < count; ++i)
            times[i] = eventTime(starts[i], stops[i]);
        return times;
    }
};

struct WindowResult {
    float median, total;
    int launches;
};

inline WindowResult summarizeWindow(std::vector<float> times) {
    float total = 0;
    for (auto ms : times) total += ms;
    std::sort(times.begin(), times.end());
    const size_t middle = times.size() / 2;
    float med = times[middle];
    if (times.size() % 2 == 0)
        med = (med + times[middle - 1]) / 2;
    return {med, total, int(times.size())};
}
