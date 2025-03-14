# DFS Symlink Setup Instructions

## Goal
Set up a symlink from `~/lean4ai` to the actual lean4ai folder in DFS location.

## Steps

1. First, navigate to your home directory:
```bash
cd ~
```

2. Create the symlink (assuming your DFS lean4ai folder is at `/dfs/scratch0/brando9/lean4ai`):
```bash
ln -s /dfs/scratch0/brando9/lean4ai ~/lean4ai
```

3. Verify the symlink was created correctly:
```bash
ls -la ~/lean4ai
```

## Moving All GitHub Repos to DFS

1. Move each repo to DFS and create symlinks:
```bash
# List of repos to symlink
repos=(
    "beyond-scale-2-alignment-coeff"
    "Compel"
    "KoyejoLab-Predictable-LLM-Evals"
    "LESS"
    "lean4ai"
    "lm-evaluation-harness"
    "mathlib4"
    "putnam-axiom"
    "self-opt-data-gen"
    "SHED-Shapley-Based-Automated-Dataset-Refinement"
    "ultimate-utils"
)

# Move each repo and create symlink
for repo in "${repos[@]}"; do
    if [ -d ~/"$repo" ] && [ ! -L ~/"$repo" ]; then
        echo "Processing repository: $repo"
        echo "Moving $repo from ~/\"$repo\" to /dfs/scratch0/brando9/"
        mv ~/"$repo" /dfs/scratch0/brando9/
        echo "Creating symlink for $repo"
        ln -s /dfs/scratch0/brando9/"$repo" ~/"$repo"
        echo "Successfully moved and linked $repo"
        echo "------------------------"
    else
        echo "Skipping $repo (not found or already a symlink)"
    fi
done

# For keys (which is already in DFS)
echo "Processing keys directory (special case)"
rm -rf ~/keys
ln -s /dfs/scratch0/brando9/keys ~/keys
echo "Successfully linked keys directory"

# Verify all symlinks
echo "Verifying all symlinks:"
ls -la ~ | grep -E "beyond-scale|Compel|KoyejoLab|LESS|lean4ai|lm-evaluation|mathlib4|putnam|self-opt|SHED|ultimate-utils|keys"
```

The commands are now simplified to:
1. Move repos directly to `/dfs/scratch0/brando9/`
2. Create symlinks from home to that DFS location
3. Handle the keys directory separately since it's already in DFS
