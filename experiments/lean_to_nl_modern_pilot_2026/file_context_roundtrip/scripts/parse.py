import re,sys,json,glob
pre=sys.argv[1]
res={}
for f in sorted(glob.glob(f'rt/{pre}_*.out')):
    for l in open(f):
        m=re.search(r'RT pilot_(p\d+) (tier1|tier2|fail)',l)
        if m: res[m.group(1)]=m.group(2)
json.dump(res,open(f'res_{pre}.json','w'))
from collections import Counter
print(len(res),Counter(res.values()))
