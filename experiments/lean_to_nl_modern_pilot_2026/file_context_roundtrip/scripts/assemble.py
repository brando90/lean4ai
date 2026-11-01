import json,re,sys,glob
# usage: assemble.py <rt_json> <outprefix> <chunk>
rt=json.load(open(sys.argv[1]))  # id -> lean string (re-formalisation)
pre=sys.argv[2]; chunk=int(sys.argv[3])
rows={r['id']:r for r in json.load(open('pairs_v2.json'))}
hdr=open('/var/lib/agent/scratch/AT-2349/lean4ai/experiments/lean_to_nl_modern_pilot_2026/compile_check_200.lean').read().split('\n')[:5]
rt_hdr=open('rt/Rt.lean').read().split('\n',1)[1]  # drop 'import Mathlib'
ids=[i for i in rows if i in rt]
files=[]
for c in range(0,len(ids),chunk):
    sub=ids[c:c+chunk]
    out=hdr+[rt_hdr,'']
    for i in sub:
        x=rt[i].strip()
        x=re.sub(r'theorem\s+\S+',f'theorem rt_{i}',x,count=1)
        x=re.sub(r':=\s*by\s+sorry\s*$|:=\s*sorry\s*$','',x).rstrip()
        out.append(f'-- {i}')
        out.append(rows[i]['lean_statement']+' := by sorry')
        out.append(x+' := by sorry')
        out.append(f'#rt pilot_{i} rt_{i}')
        out.append('')
    fn=f'{pre}_{c//chunk}.lean'; open(fn,'w').write('\n'.join(out)); files.append(fn)
print(files)
