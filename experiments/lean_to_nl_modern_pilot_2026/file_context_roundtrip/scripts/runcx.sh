#!/bin/bash
# usage: runcx.sh k   (re-formalise batch k with codex, no tools)
cd /var/lib/agent/scratch/AT-2380/cx
k=$1
cat prompt2.txt in_$k.json | codex exec --skip-git-repo-check -s read-only -C /var/lib/agent/scratch/AT-2380/cx -o ans_$k.txt - > log_$k.txt 2>&1
