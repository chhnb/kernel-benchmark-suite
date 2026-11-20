#pragma once
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <stdexcept>
#include <vector>
#include <cstring>
namespace fs=std::filesystem;
inline void need(bool b,const std::string&s){if(!b)throw std::runtime_error(s);}
struct Options {
 std::string kernel,input,output,mode="validate",timing="event";int warmup=2,repeat=5;
 std::string reference,candidate;
 int windows=1,allocations=0;
 Options(int argc,char**argv,bool measurement=false){for(int i=1;i<argc;i++){std::string k=argv[i];if(k=="--help"){std::cout<<"--kernel FILE --input FILE_OR_DIR --output NEW_DIR --mode validate|benchmark --timing event|graph --warmup N --repeat N";if(measurement)std::cout<<" [--reference FILE --candidate FILE --windows N | --allocations N]";std::cout<<"\n";std::exit(0);}need(i+1<argc,"missing value for "+k);std::string v=argv[++i];if(k=="--kernel")kernel=v;else if(k=="--input")input=v;else if(k=="--output")output=v;else if(k=="--mode")mode=v;else if(k=="--timing")timing=v;else if(k=="--warmup")warmup=std::stoi(v);else if(k=="--repeat")repeat=std::stoi(v);else if(measurement&&k=="--reference")reference=v;else if(measurement&&k=="--candidate")candidate=v;else if(measurement&&k=="--windows")windows=std::stoi(v);else if(measurement&&k=="--allocations")allocations=std::stoi(v);else throw std::runtime_error("unknown option "+k);}
 need(!kernel.empty()&&!input.empty()&&!output.empty(),"kernel/input/output required");need(mode=="validate"||mode=="benchmark","invalid mode");need(timing=="event"||timing=="graph","invalid timing");need(warmup>=0&&repeat>0,"invalid rounds");need(reference.empty()==candidate.empty(),"reference and candidate must be supplied together");
 need(windows>=1&&allocations>=0,"invalid measurement windows");
 if(!reference.empty()||allocations>0||windows!=1)
  need(mode=="benchmark"&&timing=="event"&&(!reference.empty()?allocations==0:windows==1),"invalid extended measurement mode");
 need(!fs::exists(output),"output must be new");fs::create_directories(output);
 }
 int rounds()const{return mode=="validate"?1:warmup+repeat;}
 bool measured(int i)const{return mode=="benchmark"&&i>=warmup;}
};
inline std::vector<unsigned char> readbytes(const fs::path&p){std::ifstream f(p,std::ios::binary|std::ios::ate);need(bool(f),"open "+p.string());auto n=f.tellg();need(n>=0,"size");std::vector<unsigned char>b(static_cast<size_t>(n));f.seekg(0);if(n)f.read((char*)b.data(),n);need(bool(f),"read "+p.string());return b;}
inline void writebytes(const fs::path&p,const std::vector<unsigned char>&b){std::ofstream f(p,std::ios::binary);f.write((const char*)b.data(),b.size());need(bool(f),"write "+p.string());}
