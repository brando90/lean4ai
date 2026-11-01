import json,re,sys,subprocess,os
src=sys.argv[1]; dst=sys.argv[2]
sel=json.load(open(src))
unis=set()
stm={}
for r in sel:
    sig=r['signature']
    m=re.match(re.escape(r['name'])+r'(\.\{([^}]*)\})?',sig)
    if m and m.group(2): unis.update(x.strip() for x in m.group(2).split(','))
    rest=sig[m.end():]
    r['lean_stmt']='theorem pilot_'+r['id']+rest
out=['import Mathlib','set_option autoImplicit false','set_option maxHeartbeats 400000','open scoped BigOperators Topology Pointwise ENNReal NNReal','universe '+' '.join(sorted(unis)),'']
pos={}
for r in sel:
    pos[r['id']]=len(out)+1
    out.append(r['lean_stmt']+' := by\n  sorry\n')
open(dst+'.lean','w').write('\n'.join(out)+'\n')
env=dict(os.environ); env['PATH']=os.path.expanduser('~/.elan/bin')+':'+env['PATH']
p=subprocess.run(['lake','--dir','../mathlib4','env','lean',dst+'.lean'],capture_output=True,text=True,env=env)
open(dst+'.out','w').write(p.stdout+p.stderr)
errs=[int(m.group(1)) for m in re.finditer(r'^'+re.escape(dst)+r'\.lean:(\d+):\d+: error',p.stdout,re.M)]
ids=sorted(pos,key=lambda k:pos[k])
starts=[pos[i] for i in ids]
bad=set()
import bisect
for e in errs:
    k=bisect.bisect_right(starts,e)-1
    if k>=0: bad.add(ids[k])
for r in sel: r['compiles']= r['id'] not in bad
json.dump(sel,open(dst+'.json','w'),ensure_ascii=False)
print('total',len(sel),'compile',sum(r['compiles'] for r in sel),'fail',len(bad),'unis',len(unis))
