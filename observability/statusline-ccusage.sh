#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
GRAY='\033[0;90m'
LIGHT_GRAY='\033[0;37m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Read JSON input from stdin
input=$(cat)

# Debug: Log the input to a file for troubleshooting
echo "$(date): INPUT: $input" >> /tmp/statusline-debug.log

# Extract current session ID and model info from Claude Code input
session_id=$(echo "$input" | jq -r '.session_id // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# Get current git branch with error handling
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    if [ -z "$branch" ]; then
        branch="detached"
    fi
    
    # Check for pending changes (staged or unstaged)
    if ! git diff-index --quiet HEAD -- 2>/dev/null || ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
        # Get line changes for unstaged and staged changes
        unstaged_stats=$(git diff --numstat 2>/dev/null | awk '{added+=$1; deleted+=$2} END {print added+0, deleted+0}')
        staged_stats=$(git diff --cached --numstat 2>/dev/null | awk '{added+=$1; deleted+=$2} END {print added+0, deleted+0}')
        
        # Parse the stats
        unstaged_added=$(echo $unstaged_stats | cut -d' ' -f1)
        unstaged_deleted=$(echo $unstaged_stats | cut -d' ' -f2)
        staged_added=$(echo $staged_stats | cut -d' ' -f1)
        staged_deleted=$(echo $staged_stats | cut -d' ' -f2)
        
        # Total changes
        total_added=$((unstaged_added + staged_added))
        total_deleted=$((unstaged_deleted + staged_deleted))
        
        # Build the branch display with changes (with colors)
        changes=""
        if [ $total_added -gt 0 ]; then
            changes="${GREEN}+$total_added${RESET}"
        fi
        if [ $total_deleted -gt 0 ]; then
            if [ -n "$changes" ]; then
                changes="$changes ${RED}-$total_deleted${RESET}"
            else
                changes="${RED}-$total_deleted${RESET}"
            fi
        fi
        
        if [ -n "$changes" ]; then
            branch="$branch${PURPLE}*${RESET} ($changes)"
        else
            branch="$branch${PURPLE}*${RESET}"
        fi
    fi
else
    branch="no-git"
fi

# Get basename of ACTUAL current directory (ignore Claude Code's incorrect workspace info)
dir_name=$(basename "$(pwd)")

# Get today's date in YYYYMMDD format
today=$(date +%Y%m%d)

# Function to format numbers
format_cost() {
    printf "%.2f" "$1"
}

format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000000 ]; then
        printf "%.1fM" "$(echo "scale=1; $tokens / 1000000" | bc -l)"
    elif [ "$tokens" -ge 1000 ]; then
        printf "%.1fK" "$(echo "scale=1; $tokens / 1000" | bc -l)"
    else
        printf "%d" "$tokens"
    fi
}

format_time() {
    local minutes=$1
    local hours=$((minutes / 60))
    local mins=$((minutes % 60))
    if [ "$hours" -gt 0 ]; then
        printf "%dh %dm" "$hours" "$mins"
    else
        printf "%dm" "$mins"
    fi
}

# Function to create progress bar
create_progress_bar() {
    local percentage=$1
    local width=10  # Width of the progress bar in characters
    local filled_width=$((percentage * width / 100))
    local empty_width=$((width - filled_width))
    
    # Choose color based on percentage
    local color=""
    if [ "$percentage" -ge 80 ]; then
        color="$RED"
    elif [ "$percentage" -ge 60 ]; then
        color="$YELLOW"
    else
        color="$GREEN"
    fi
    
    # Build the progress bar
    local bar="${color}"
    for ((i=0; i<filled_width; i++)); do
        bar="${bar}█"
    done
    bar="${bar}${GRAY}"
    for ((i=0; i<empty_width; i++)); do
        bar="${bar}░"
    done
    bar="${bar}${RESET}"
    
    printf "%s" "$bar"
}

# Initialize variables with defaults
session_cost="0.00"
session_tokens=0
daily_cost="0.00"
block_cost="0.00"
remaining_time="N/A"
block_percentage=0

# Get current session cost directly from Claude Code input
session_cost_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // "0.00"')
if [ -n "$session_cost_raw" ] && [ "$session_cost_raw" != "null" ] && [ "$session_cost_raw" != "0.00" ]; then
    session_cost="$session_cost_raw"
fi

# Get session token count from input (if available)
input_tokens=$(echo "$input" | jq -r '.cost.total_lines_added // 0' 2>/dev/null || echo "0")
output_tokens=$(echo "$input" | jq -r '.cost.total_lines_removed // 0' 2>/dev/null || echo "0")
if [ "$input_tokens" != "0" ] || [ "$output_tokens" != "0" ]; then
    # Rough approximation using lines changed as proxy for activity
    session_tokens=$((input_tokens + output_tokens))
fi

# Cache for 30 seconds to avoid multiple ccusage calls
CACHE_FILE="/tmp/ccusage-cache-$today"
CACHE_AGE=30

# Use full path to ccusage since it may not be in PATH in all projects
CCUSAGE_PATH="/Users/flo/.nvm/versions/node/v22.17.1/bin/ccusage"
if [ -x "$CCUSAGE_PATH" ]; then
    target_dir="${cwd:-$current_dir}"
    cd "$target_dir" 2>/dev/null || cd "$(pwd)"
    
    # Check if cache is fresh
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $CACHE_AGE ]; then
        # Use cached data
        daily_cost=$(cat "$CACHE_FILE" 2>/dev/null || echo "0")
    else
        # Fetch fresh data
        daily_data=$("$CCUSAGE_PATH" daily --json --since "$today" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$daily_data" ]; then
            daily_cost=$(echo "$daily_data" | jq -r '.totals.totalCost // 0')
            echo "$daily_cost" > "$CACHE_FILE"
        fi
    fi
    
    # Get active block data - ensure we run from correct directory  
    target_dir="${cwd:-$current_dir}"
    cd "$target_dir" 2>/dev/null || cd "$(pwd)"
    block_data=$("$CCUSAGE_PATH" blocks --active --json 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$block_data" ]; then
        active_block=$(echo "$block_data" | jq -r '.blocks[] | select(.isActive == true) // empty')
        if [ -n "$active_block" ] && [ "$active_block" != "null" ]; then
            block_cost=$(echo "$active_block" | jq -r '.costUSD // 0')
            remaining_minutes=$(echo "$active_block" | jq -r '.projection.remainingMinutes // 0')
            if [ "$remaining_minutes" != "0" ] && [ "$remaining_minutes" != "null" ]; then
                remaining_time=$(format_time "$remaining_minutes")
            fi
            
            # Calculate block usage percentage using projected cost
            projected_cost=$(echo "$active_block" | jq -r '.projection.totalCost // 0')
            if [ "$projected_cost" != "0" ] && [ "$projected_cost" != "null" ]; then
                # Calculate current usage percentage based on projection
                # block_cost / projected_cost * 100
                if command -v bc >/dev/null 2>&1; then
                    block_percentage=$(echo "scale=0; $block_cost * 100 / $projected_cost" | bc -l 2>/dev/null || echo "0")
                else
                    # Fallback without bc
                    block_percentage=$(( block_cost * 100 / projected_cost ))
                fi
                # Ensure percentage is between 0 and 100
                if [ "$block_percentage" -gt 100 ]; then
                    block_percentage=100
                elif [ "$block_percentage" -lt 0 ]; then
                    block_percentage=0
                fi
            fi
        fi
    fi
fi

# Format the output
formatted_session_cost=$(format_cost "$session_cost")
formatted_daily_cost=$(format_cost "$daily_cost")
formatted_block_cost=$(format_cost "$block_cost")
formatted_tokens=$(format_tokens "$session_tokens")

# Build the status line with colors (light gray as default)
status_line="${LIGHT_GRAY}🌿 $branch ${GRAY}|${LIGHT_GRAY} 📁 $dir_name ${GRAY}|${LIGHT_GRAY} 🤖 $model_name ${GRAY}|${GREEN} 💰 \$$formatted_session_cost ${GRAY}/${PURPLE} 📅 \$$formatted_daily_cost ${GRAY}/${LIGHT_GRAY} 🧊 \$$formatted_block_cost"

if [ "$remaining_time" != "N/A" ]; then
    status_line="$status_line ${GRAY}(${LIGHT_GRAY}$remaining_time left${GRAY})"
fi

# Add progress bar if we have block percentage
if [ "$block_percentage" -gt 0 ]; then
    progress_bar=$(create_progress_bar "$block_percentage")
    status_line="$status_line ${GRAY}|${LIGHT_GRAY} 🔋 ${RESET}$progress_bar ${LIGHT_GRAY}${block_percentage}%"
fi

status_line="$status_line ${GRAY}|${LIGHT_GRAY} 🧩 ${formatted_tokens} ${GRAY}tokens${RESET}"

printf "%b\n" "$status_line"

