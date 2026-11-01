#!/bin/bash
# usage: run_lean.sh file.lean  -> prints output
export PATH=$HOME/.elan/bin:$PATH
cd /var/lib/agent/scratch/AT-2349/mathlib4
exec lake env lean "$1"
