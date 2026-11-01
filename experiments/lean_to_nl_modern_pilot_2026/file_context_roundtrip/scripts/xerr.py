import re,sys,json,glob
pre=sys.argv[1]
xerr={}  # id -> list of error msgs inside X statement
for f in sorted(glob.glob(f'rt/{pre}_*.lean')):
    L=open(f).read().split('\n')
    spans={}  # id -> (xstart,xend) 1-based lines of rt theorem up to before #rt
    cur=None
    for n,l in enumerate(L,1):
        m=re.match(r'theorem rt_(p\d+)',l) or re.match(r'open .* in theorem rt_(p\d+)',l)
        if m: cur=m.group(1); spans[cur]=[n,n]
        if l.startswith('#rt') and cur: spans[cur][1]=n-1; cur=None
    out=open(f.replace('.lean','.out')).read()
    for m in re.finditer(re.escape(f)+r':(\d+):\d+: error[^\n]*(\n(?!/var)[^\n]*){0,6}',out):
        ln=int(m.group(1))
        for i,(a,b) in spans.items():
            if a<=ln<=b: xerr.setdefault(i,[]).append(m.group(0)[:600].replace(f,'F'))
json.dump(xerr,open(f'xerr_{pre}.json','w'),ensure_ascii=False)
print(len(xerr))
