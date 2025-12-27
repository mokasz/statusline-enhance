#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract token usage from context_window (recommended approach)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
CURRENT_USAGE=$(echo "$input" | jq '.context_window.current_usage')

if [ "$CURRENT_USAGE" != "null" ]; then
    # Calculate current context from current_usage fields
    INPUT_TOKENS=$(echo "$CURRENT_USAGE" | jq '.input_tokens // 0')
    OUTPUT_TOKENS=$(echo "$CURRENT_USAGE" | jq '.output_tokens // 0')
    CACHE_CREATE=$(echo "$CURRENT_USAGE" | jq '.cache_creation_input_tokens // 0')
    CACHE_READ=$(echo "$CURRENT_USAGE" | jq '.cache_read_input_tokens // 0')

    # 全トークンタイプを合計
    CURRENT_TOKENS=$((INPUT_TOKENS + OUTPUT_TOKENS + CACHE_CREATE + CACHE_READ))
    REMAINING=$((CONTEXT_SIZE - CURRENT_TOKENS))
    PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
else
    # Fallback if context_window is not available
    CURRENT_TOKENS=0
    REMAINING=$CONTEXT_SIZE
    PERCENT_USED=0
fi

# Color based on usage percentage
if [ $PERCENT_USED -gt 70 ]; then
    BUDGET_COLOR="\033[31m"  # Red (high usage)
elif [ $PERCENT_USED -ge 30 ]; then
    BUDGET_COLOR="\033[33m"  # Yellow (medium usage)
else
    BUDGET_COLOR="\033[32m"  # Green (low usage)
fi

# Extract working directory
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
if [ -z "$CWD" ]; then
    CWD="$HOME"
fi
cd "$CWD" 2>/dev/null || cd "$HOME"

# Git branch information
BRANCH=$(git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
DIRTY=""
if [ -n "$BRANCH" ] && [[ $(GIT_OPTIONAL_LOCKS=0 git status --porcelain 2>/dev/null) ]]; then
    DIRTY="*"
fi
GIT_INFO=""
if [ -n "$BRANCH" ]; then
    GIT_INFO=" ($BRANCH$DIRTY)"
fi

# Output the status line
printf "%b[%dk/%dk]%b %b%s%b%s%b" \
    "$BUDGET_COLOR" \
    "$((REMAINING / 1000))" \
    "$((CONTEXT_SIZE / 1000))" \
    "\033[00m" \
    "\033[32m" \
    "$CWD" \
    "\033[33m" \
    "$GIT_INFO" \
    "\033[00m"
