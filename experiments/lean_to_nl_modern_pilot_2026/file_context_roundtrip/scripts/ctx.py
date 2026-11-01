import json,re
P='/var/lib/agent/scratch/AT-2349/'
pairs=[json.loads(l) for l in open(P+'lean4ai/experiments/lean_to_nl_modern_pilot_2026/pairs_all.jsonl')]
cand={}
for l in open(P+'work/candidates_full.jsonl'):
    c=json.loads(l); cand[(c['name'],c['module'])]=c
out=[];miss=0
keep=re.compile(r'^\s*(namespace|section|open|variable|universe|local notation|notation|local macro|scoped notation|local infix|private def|noncomputable def|def|abbrev|structure|class|instance|inductive|irreducible_def|noncomputable abbrev|noncomputable instance|local instance|attribute)\b')
for p in pairs:
    c=cand.get((p['mathlib_decl'],p['module']))
    if c is None:
        c=next((v for k,v in cand.items() if k[1]==p['module'] and k[0].endswith(p['mathlib_decl'])),None)
    if c is None: miss+=1; out.append(dict(id=p['id'],context='')); continue
    f=P+'mathlib4/'+p['module'].replace('.','/')+'.lean'
    L=open(f).read().split('\n')
    st=c['start']-1
    # include docstring/attrs above
    pre=L[:st]
    # file header: first 'namespace/open/variable' items; build compact
    chunks=[];i=0
    while i<len(pre):
        if keep.match(pre[i]):
            j=i;blk=[pre[i]]
            # docstring above
            k=i-1
            if k>=0 and pre[k].strip().endswith('-/'):
                d=[];
                while k>=0:
                    d.append(pre[k])
                    if pre[k].lstrip().startswith('/--') or pre[k].lstrip().startswith('/-'): break
                    k-=1
                blk=d[::-1]+blk
            # continuation lines up to := or where
            m=i
            while m+1<len(pre) and not re.search(r':=|\bwhere\b|^\s*$',pre[m]) and m-i<6 and re.match(r'^\s+',pre[m+1]):
                m+=1; blk.append(pre[m])
            chunks.append('\n'.join(blk)); i=m+1
        else: i+=1
    ctx='\n'.join(chunks)
    if len(ctx)>7000: ctx='...(earlier context omitted)\n'+ctx[-7000:]
    near='\n'.join(pre[max(0,st-25):st])
    out.append(dict(id=p['id'],context=ctx,nearby=near))
json.dump(out,open('ctx.json','w'),ensure_ascii=False)
print(miss,[len(o['context']) for o in out][:20],sum(len(o['context'])+len(o.get('nearby','')) for o in out)/200)
