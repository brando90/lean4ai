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
    "veribench"
)

# Function to format time in a readable way
format_time() {
    local seconds=$1
    local minutes=$((seconds/60))
    local remaining_seconds=$((seconds%60))
    echo "${minutes}m ${remaining_seconds}s"
}

# Move each repo and create symlink
echo "Starting repository moves at $(date)"
for repo in "${repos[@]}"; do
    if [ -d ~/"$repo" ] && [ ! -L ~/"$repo" ]; then
        echo "Processing repository: $repo"
        echo "Moving $repo from ~/\"$repo\" to /dfs/scratch0/brando9/"
        
        # Get size before moving
        size=$(du -sh ~/"$repo" 2>/dev/null | cut -f1)
        
        # Time the move operation
        start_time=$(date +%s)
        mv ~/"$repo" /dfs/scratch0/brando9/
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        echo "Creating symlink for $repo"
        ln -s /dfs/scratch0/brando9/"$repo" ~/"$repo"
        echo "Successfully moved and linked $repo"
        echo "Size: ${size}, Time taken: $(format_time $duration)"
        echo "------------------------"
    else
        echo "Skipping $repo (not found or already a symlink)"
    fi
done
echo "Finished repository moves at $(date)"

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

The script now provides:
- Start and end timestamps for the entire operation
- Size of each repository being moved
- Time taken for each move operation
- Progress tracking with clear visual separators
