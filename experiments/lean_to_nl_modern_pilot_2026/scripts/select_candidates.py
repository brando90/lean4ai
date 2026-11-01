"""Select the pilot items from work/candidates_full.jsonl (written by dump_old_names_and_candidates.lean).
Rule used: theorem not in the Oct 2023 LeanDojo benchmark names, 40-600 char signature, 3-30 source lines,
no *.eq_N / *_def names, stratified over top-level Mathlib folders with weights sqrt(folder size), seed 2349,
shuffled, 299 kept; then compile_check_statements.py keeps those whose statement compiles; first 200 compiling
(166 from the first draw plus 34 more from the same draw after fixing a line-number bug in the compile filter)."""
import json,random,collections,math
rows=[json.loads(l) for l in open('candidates_full.jsonl') if l.strip()]
for r in rows: r['area']=r['module'].split('.')[1]
new=[r for r in rows if not r['in_old_benchmark']]
ok=[r for r in new if 40<=len(r['signature'])<=600 and 3<=r['end']-r['start']+1<=30 and not r['name'].endswith(('_def','.eq_1')) and '.eq_' not in r['name']]
random.seed(2349)
by=collections.defaultdict(list)
for r in ok: by[r['area']].append(r)
tot=sum(math.sqrt(len(v)) for v in by.values())
sel=[]
for a in sorted(by,key=lambda a:-len(by[a])):
    k=max(1,round(300*math.sqrt(len(by[a]))/tot)); sel+=random.sample(by[a],min(k,len(by[a])))
random.shuffle(sel); sel=sel[:300]
for i,r in enumerate(sel): r['id']=f'p{i:03d}'
json.dump(sel,open('selected300.json','w'),ensure_ascii=False)
