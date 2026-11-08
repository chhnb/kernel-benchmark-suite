#!/usr/bin/env python3
"""Build a self-contained stage report from retained experimental evidence."""
import argparse,json,math,html,statistics
from pathlib import Path
S=Path(__file__).resolve().parents[1]
def load(p):return json.loads(p.read_text())
def table(headers,rows):
 return "<table><thead><tr>"+"".join("<th>"+html.escape(str(x))+"</th>" for x in headers)+"</tr></thead><tbody>"+"".join("<tr>"+"".join("<td>"+html.escape(str(x))+"</td>" for x in r)+"</tr>" for r in rows)+"</tbody></table>"
def main():
 p=argparse.ArgumentParser();p.add_argument("--out",type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 data={"stage":"experimental V0/V1/V2; not calibrated or deployment-approved","coverage":[],"full_pipeline":[],"samples":[]}
 for name,directory in [("Landau","canonical-stable-1"),("Map-Airy","mapairy-supported"),("TIGRE","tigre-v2"),("SRAD","srad-v2"),("Hypersonic","hypersonic-v2"),("Cholla","cholla-v2")]:
  d=S/"work/postopt"/directory;rows=[load(f) for f in d.glob("trial-*/trial.json")]
  valid=[r for r in rows if r["valid"]];scored=[r for r in valid if r["score_result"]["status"]=="scored"]
  times=[r["timings_ms"]["trial_total"]+r["timings_ms"]["score_with_analysis"] for r in rows]
  data["coverage"].append({"program":name,"trials":len(rows),"legal":len(valid),"scored":len(scored),
    "native_profitable":sum(r["original_darm_profitable"] for r in valid),
    "v1_accept":sum(r["score_result"]["static_gain"]>0 and r["score_result"]["static_score"]>0 for r in scored),
    "v2_accept":sum(r["eligible"] for r in valid),"median_candidate_ms":statistics.median(times) if times else None,"source":str(d)})
 full=S/"experiments/postopt-full-landau-v1"
 for variant in ["v1","v2","original","original_clean"]:
  r=load(full/(variant+"-measure")/"labels.json")
  row={"variant":variant,"status":r["status"],"inputs":{}}
  for key,value in r["inputs"].items():
   row["inputs"][key]={"speedup":math.exp(value["mean_log_ratio"]),"runtime_change_percent":100*(math.exp(-value["mean_log_ratio"])-1),"label":value["label"],"log_ratio_batch_range":value["observed_batch_range"]}
  if variant in ["v1","v2"]:
   row["search"]=load(S/f"work/postopt/landau-continuous-final-{variant}/result.json")
   row["seconds"]=load(S/f"work/postopt/landau-continuous-final-{variant}.time.json")["seconds"]
  data["full_pipeline"].append(row)
 for name,folder in [("Landau","postopt-stable-landau-sample-v1"),("Map-Airy","postopt-stable-mapairy-sample-v2"),("TIGRE","postopt-tigre-sample-v1"),("SRAD","postopt-srad-sample-v1"),("Hypersonic","postopt-hypersonic-sample-v1")]:
  d=S/"experiments"/folder
  for f in d.glob("*-measure/labels.json"):
   actual=f.with_name("labels-tigre-v1.json") if name=="TIGRE" else f.with_name("labels-fluid-v1.json") if name=="Hypersonic" else f
   r=load(actual)
   data["samples"].append({"program":name,"stratum":f.parent.name,"status":r["status"],"labels":{k:v["label"] for k,v in r["inputs"].items()},"source":str(actual)})
 r=load(S/"experiments/postopt-native-rejected-landau-measure-v1/labels.json")
 data["samples"].append({"program":"Landau","stratum":"native-rejected-v2-accepted","status":r["status"],"labels":{k:v["label"] for k,v in r["inputs"].items()},"source":str(S/"experiments/postopt-native-rejected-landau-measure-v1/labels.json")})
 data["cache_validation"]=load(S/"work/postopt/landau-continuous-cached-v2/cache-comparison.json")
 (a.out/"report.json").write_text(json.dumps(data,indent=2))
 body="""<h1>后优化 IR 启发式：V0–V2 阶段报告</h1>
<p>实现已支持独立选择 V1/V2、固定快照的合法候选成对实验、完整函数活跃值压力和离线标签。当前参数未经校准，尚未证明 V2 优于 V1，也未通过未见程序家族的部署验收。</p>
<h2>编译时模型</h2><p>两侧使用同一清理流程；V1 比较 TTI reciprocal-throughput 静态工作量，V2 加上相对压力增长惩罚。示例压力系数为 0.1，不是已验证最优值。评分过程不运行后端、不读取硬件计数器。LLVM12 不支持的 freeze 显式使用 32 位槽位回退；fence、switch 仍保守拒绝。uniformity、PHI 边使用和循环活跃值均已建模。</p>
<h2>固定候选覆盖</h2><p>原 DARM 列是同一候选的原生盈利性判断，不代表原生搜索一定会枚举该候选。输入来自现有项目快照；表格不是训练/验证/测试划分。</p>"""
 body+=table(["程序","候选","合法","可评分","原生盈利","V1 接受","V2 接受","候选中位 ms"],[[r[k] if k!="median_candidate_ms" else round(r[k],3) for k in ("program","trials","legal","scored","native_profitable","v1_accept","v2_accept","median_candidate_ms")] for r in data["coverage"]])
 body+="<h2>Landau 连续决策结果</h2><p>相对无合并且经过相同清理的基线。三批交替计时，每批预热 2 次、测量 5 次；完整输出逐次校验。下表是运行时间变化：负数更快，正数更慢。观察到的批次范围不是置信区间。</p>"
 rows=[]
 for r in data["full_pipeline"]:
  vals=[r["variant"],r["status"]]
  for key in ["0","1"]:vals.append((f'{r["inputs"][key]["runtime_change_percent"]:+.2f}%') if key in r["inputs"] else "无完整标签")
  vals.append(round(r["seconds"],2) if "seconds" in r else "未纳入同口径搜索成本")
  rows.append(vals)
 body+=table(["版本","状态","混合输入","一致输入","搜索秒数"],rows)
 body+="""<p>V1/V2 各限制为 8 次提交，原 DARM 使用自身搜索与停止规则；搜索空间和迭代预算不同。因此此表不能单独归因于评分器。V2 的一致输入仍约慢 9.34%，原 DARM＋清理约慢 32.77%；V1 与 V2 差异不足以证明压力模型更优。原 DARM 单独版本遭 admission 拒绝，未自动重试，不能补造结果。</p>
<h2>成对候选实验</h2>"""
 body+=table(["程序","样本层","状态","按输入的标签"],[[r["program"],r["stratum"],r["status"],json.dumps(r["labels"],ensure_ascii=False)] for r in data["samples"]])
 body+="""<p>新增 Hypersonic 正分候选在两个输入上的平均变化约 0.2%，均低于预设 2% 效果阈值，标为效果不明确。原 DARM 拒绝但 V2 接受的 Landau 候选也在两个输入上效果不明确；尚未证明找回了有效机会。SRAD 的合法候选仍因 fence 代价缺失而拒绝评分，离线实测为效果不明确。Cholla 的 switch 代价缺失同样明确标记 unsupported。</p><h2>验证与修复</h2><p>测试覆盖 PHI 边使用、循环固定点、参数活跃值、类型权重、uniformity、被删除/保留的 select、相同优化 IR 零收益、缓存复用、过期轮次、未知代价与不完整标签。109 个候选已在三个独立进程中验证标识、IR 哈希和评分一致。修复了融合清理删除块后仍访问指令的释放后使用；稳定化 Region 遍历及 PHI incoming 顺序。所有旧失败日志保留。</p>
<h2>边界和下一步</h2><ul>
<li>现有完整候选标签以少量分层极值为主，不能支持代表性误接受率、机会保留率或独立测试泛化结论；没有把“全拒绝”当作成功。</li>
<li>局部压力取变化基本块的文本范围，跨块值指标不等于整个 Region 的精确来源映射；IR 槽位不是分配后的 VGPR/SGPR。</li>
<li>编号缓存优化后，同一 614 个候选的评分、局部特征和最终 IR 完全一致，V2 搜索从 139.88 秒降至 35.58 秒（各一次计时）。上表保留原始未缓存测量；仍需配置预算并验证部署成本。</li>
<li>V3 依赖/访存特征尚未实现。先用错误案例决定模块，避免未经证实的复杂成本公式。</li>
<li>V4 需要增加真正独立的程序家族、冻结配置和分组验证。当前 Landau/Map-Airy 不应被视作两个完全独立的训练/测试家族。</li>
<li>同一最终 IR 在不同输入上收益反向，支持调查 V5 的 warp/wave profile；目前未实现插桩，也不能据此声称 profile 已改善决策。</li></ul>
<h2>入口</h2><pre>tools/build-fusion-search
tests/postopt/run
tools/postopt_pair.py
tools/postopt_measure.py
tools/postopt_sample.py
tools/postopt_report.py
tools/postopt_resources.py
tests/postopt/replay.py</pre><p>详细参数和限制见远端 docs/postopt-heuristic.txt；机器可读数据与本报告并列为 report.json。原始 IR、命令、样本、资源报告及 admission 记录保留在远端 experiments/ 和 work/postopt/。</p>"""
 page='<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>Post-opt IR V0–V2</title><style>body{max-width:1100px;margin:36px auto;padding:0 22px;font:16px/1.65 system-ui;color:#203047}table{border-collapse:collapse;width:100%;font-size:14px}th,td{border:1px solid #cdd6df;padding:8px;text-align:left}th{background:#edf2f7}h1,h2{line-height:1.3}pre{background:#edf2f7;padding:18px;overflow:auto}</style>'+body+"</html>"
 (a.out/"report.html").write_text(page)
 print(a.out)
if __name__=="__main__":main()
