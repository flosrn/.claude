#!/bin/bash
# Bidirectional sync between local Mac and VPS (Docker container)
# Usage: sync-vps.sh [--dry-run] [--pull] [--status] [-i|--interactive] [--sync] [repo...]

set -uo pipefail

VPS="vps"
CONTAINER="openclaw-gateway"
DRY_RUN=""
DIRECTION="push"
STATUS_ONLY=""
INTERACTIVE=""
COMMIT_MSG=""

REPO_DEFS=(
  "dot-claude|$HOME/.claude|/home/node/.claude|main"
  "shipmate-agent|$HOME/Code/claude/shipmate-agent|/home/node/.openclaw/workspace-shipmate|main"
  "shipmate-bot|$HOME/Code/claude/shipmate-bot|/home/node/projects/shipmate-bot|main"
  "shipmate|$HOME/Code/claude/shipmate|/home/node/projects/shipmate|main"
  "clawd|$HOME/Code/claude/clawd|/home/node/.openclaw/workspace|main"
  "gapibot|$HOME/Code/claude/gapibot|/home/node/.openclaw/workspace-gapibot|main"
  "gapila|$HOME/Code/nextjs/gapila|/home/node/projects/gapila|main"
  "shared-skills|$HOME/Code/claude/shared-skills|/home/node/shared-skills|main"
  "openclaw-config|$HOME/Code/claude/openclaw-config|/opt/docker/openclaw|main"
)

# Repos that contain skills → which agents they affect
# shared-skills affects all agents, workspace repos affect their own agent
SKILL_REPO_MAP=(
  "clawd|default"
  "gapibot|gapibot"
  "shipmate-agent|shipmate"
  "shared-skills|all"
)
SYNCED_REPOS=()  # Track which repos were actually synced

SELECTED=()

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN="1" ;;
    --pull) DIRECTION="pull" ;;
    --sync) DIRECTION="sync" ;;
    --status) STATUS_ONLY="1" ;;
    -i|--interactive) INTERACTIVE="1" ;;
    -m|--message) shift; COMMIT_MSG="${1:-}" ;;
    --help|-h)
      echo "Usage: sync-vps.sh [--dry-run] [--pull] [--sync] [--status] [-i] [-m 'msg'] [repo...]"
      echo ""
      echo "  (default)    Push Mac changes to VPS"
      echo "  --pull       Pull VPS changes to Mac"
      echo "  --sync       Bidirectional sync (commit+push both, then pull both)"
      echo "  --status     Show status of all repos"
      echo "  -i           Interactive mode (fzf)"
      echo "  -m, --message  Custom commit message (default: auto-generated)"
      echo "  --dry-run    Preview without changes"
      echo ""
      echo "  Repos: dot-claude, shipmate-agent, shipmate-bot, shipmate, clawd, gapibot, gapila"
      exit 0
      ;;
    *) SELECTED+=("$1") ;;
  esac
  shift
done

# -- Colors --
C_GREEN='\033[38;5;114m'
C_YELLOW='\033[38;5;221m'
C_RED='\033[38;5;203m'
C_BLUE='\033[38;5;111m'
C_CYAN='\033[38;5;117m'
C_DIM='\033[2m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

header() { echo -e "\n${C_BOLD}${C_BLUE}  $1${C_RESET}"; }
ok()     { echo -e "  ${C_GREEN}$1${C_RESET}"; }
info()   { echo -e "  ${C_DIM}$1${C_RESET}"; }
warn()   { echo -e "  ${C_YELLOW}$1${C_RESET}"; }
err()    { echo -e "  ${C_RED}$1${C_RESET}"; }
step()   { echo -e "  ${C_CYAN}$1${C_RESET}"; }

vps_exec() {
  echo "$1" | ssh "$VPS" "docker exec -i -u node $CONTAINER bash" 2>/dev/null
}

# For repos that need git commands on the host instead of in-container
vps_host_exec() {
  ssh "$VPS" "bash -c '$1'" 2>/dev/null
}

# Repos with host-side VPS paths (bind-mounted rw, but git runs on host for simplicity)
# Format: repo_name|host_vps_path
HOST_REPOS=(
  "shared-skills|/root/shared-skills"
  "openclaw-config|/root/openclaw-config"
)

# Resolve host path for a repo (returns empty if repo uses container)
get_host_path() {
  local repo_name="$1"
  for hr in "${HOST_REPOS[@]}"; do
    IFS='|' read -r hr_name hr_path <<< "$hr"
    if [ "$hr_name" = "$repo_name" ]; then
      echo "$hr_path"
      return 0
    fi
  done
  return 1
}

# Run a git command on VPS — routes to host or container depending on repo
vps_git() {
  local name="$1" vps_dir="$2"
  shift 2
  local cmd="$*"
  local host_path
  host_path=$(get_host_path "$name") || true
  if [ -n "$host_path" ]; then
    vps_host_exec "cd '$host_path' && $cmd"
  else
    vps_exec "cd \"$vps_dir\" && $cmd"
  fi
}

count_changes() {
  local status="${1:-}"
  if [ -z "$status" ]; then echo "0"; else echo "$status" | wc -l | tr -d ' '; fi
}

# ============================
# Status collection
# ============================
declare -a REPO_NAMES=() REPO_LOCAL_DIRS=() REPO_VPS_DIRS=() REPO_BRANCHES=()
declare -a REPO_LOCAL_STATUS=() REPO_VPS_STATUS=()
declare -a REPO_LOCAL_BRANCH=() REPO_VPS_BRANCH=()
declare -a REPO_LOCAL_COUNT=() REPO_VPS_COUNT=()
declare -a REPO_SYNCABLE=()

collect_status() {
  echo -ne "${C_DIM}  Fetching...${C_RESET}"

  for def in "${REPO_DEFS[@]}"; do
    IFS='|' read -r name local_dir vps_dir branch <<< "$def"
    REPO_NAMES+=("$name")
    REPO_LOCAL_DIRS+=("$local_dir")
    REPO_VPS_DIRS+=("$vps_dir")
    REPO_BRANCHES+=("$branch")

    if [ -n "$local_dir" ] && [ -d "$local_dir/.git" ]; then
      local lst
      lst=$(cd "$local_dir" && git status --short --ignore-submodules=dirty 2>/dev/null)
      REPO_LOCAL_STATUS+=("$lst")
      REPO_LOCAL_COUNT+=("$(count_changes "$lst")")
      REPO_LOCAL_BRANCH+=("$(cd "$local_dir" && git branch --show-current 2>/dev/null)")
      REPO_SYNCABLE+=("yes")
    elif [ -n "$local_dir" ]; then
      REPO_LOCAL_STATUS+=(""); REPO_LOCAL_COUNT+=("0"); REPO_LOCAL_BRANCH+=("-"); REPO_SYNCABLE+=("no")
    else
      REPO_LOCAL_STATUS+=(""); REPO_LOCAL_COUNT+=("0"); REPO_LOCAL_BRANCH+=(""); REPO_SYNCABLE+=("vps-only")
    fi
  done

  local vps_script=""
  for def in "${REPO_DEFS[@]}"; do
    IFS='|' read -r name local_dir vps_dir branch <<< "$def"
    vps_script+="echo \"===REPO:${name}===\"; "
    vps_script+="if cd \"${vps_dir}\" 2>/dev/null; then echo \"BRANCH:\$(git branch --show-current 2>/dev/null)\"; git status --short 2>/dev/null; else echo \"UNREACHABLE\"; fi; "
  done

  local vps_raw
  vps_raw=$(echo "$vps_script" | ssh "$VPS" "docker exec -i -u node $CONTAINER bash" 2>/dev/null) || vps_raw="UNREACHABLE"

  local current_repo="" current_branch="" current_status=""
  while IFS= read -r line; do
    if [[ "$line" == ===REPO:*=== ]]; then
      if [ -n "$current_repo" ]; then
        if [ "$current_status" = "UNREACHABLE" ]; then
          REPO_VPS_STATUS+=("(unreachable)"); REPO_VPS_COUNT+=("0"); REPO_VPS_BRANCH+=("?")
        else
          REPO_VPS_STATUS+=("$current_status"); REPO_VPS_COUNT+=("$(count_changes "$current_status")"); REPO_VPS_BRANCH+=("$current_branch")
        fi
      fi
      current_repo="${line#===REPO:}"; current_repo="${current_repo%===}"
      current_branch=""; current_status=""
    elif [[ "$line" == BRANCH:* ]]; then
      current_branch="${line#BRANCH:}"
    elif [[ "$line" == "UNREACHABLE" ]] && [ -z "$current_status" ]; then
      current_status="UNREACHABLE"
    elif [ -n "$line" ]; then
      if [ -n "$current_status" ] && [ "$current_status" != "UNREACHABLE" ]; then
        current_status+=$'\n'"$line"
      else
        current_status="$line"
      fi
    fi
  done <<< "$vps_raw"

  if [ -n "$current_repo" ]; then
    if [ "$current_status" = "UNREACHABLE" ]; then
      REPO_VPS_STATUS+=("(unreachable)"); REPO_VPS_COUNT+=("0"); REPO_VPS_BRANCH+=("?")
    else
      REPO_VPS_STATUS+=("$current_status"); REPO_VPS_COUNT+=("$(count_changes "$current_status")"); REPO_VPS_BRANCH+=("$current_branch")
    fi
  fi

  local vps_count="${#REPO_VPS_STATUS[@]}" expected="${#REPO_NAMES[@]}"
  while [ "$vps_count" -lt "$expected" ]; do
    REPO_VPS_STATUS+=("(unreachable)"); REPO_VPS_COUNT+=("0"); REPO_VPS_BRANCH+=("?")
    vps_count=$((vps_count + 1))
  done

  echo -e "\r\033[2K"
}

# -- Build a padded, colored status cell --
# Pad plain text first, then wrap in ANSI color (so printf counts visible chars only)
color_cell() {
  local count="$1" type="$2" width="$3"
  local text color
  if [ "$type" = "unreachable" ]; then
    text="offline"; color="38;5;203"
  elif [ "$type" = "no-clone" ]; then
    text="--"; color="2"
  elif [ "$count" -gt 0 ] 2>/dev/null; then
    text="${count} dirty"; color="38;5;221"
  else
    text="ok"; color="38;5;114"
  fi
  local padded
  padded=$(printf "%-${width}s" "$text")
  printf "\033[%sm%s\033[0m" "$color" "$padded"
}

status_line() {
  local i="$1"
  local name="${REPO_NAMES[$i]}"
  local lc="${REPO_LOCAL_COUNT[$i]:-0}"
  local vc="${REPO_VPS_COUNT[$i]:-0}"
  local syncable="${REPO_SYNCABLE[$i]:-}"
  local vps_st="${REPO_VPS_STATUS[$i]:-}"

  local mac_type="" vps_type=""
  [ "$syncable" = "vps-only" ] && mac_type="no-clone"
  [ "$vps_st" = "(unreachable)" ] && vps_type="unreachable"

  local mac_cell vps_cell
  mac_cell=$(color_cell "$lc" "$mac_type" 10)
  vps_cell=$(color_cell "$vc" "$vps_type" 10)

  printf "  %-18s%s  %s" "$name" "$mac_cell" "$vps_cell"
}

# -- Detail view --
show_detail() {
  local i="$1"
  local name="${REPO_NAMES[$i]}"
  local syncable="${REPO_SYNCABLE[$i]:-}"
  local lc="${REPO_LOCAL_COUNT[$i]:-0}"
  local vc="${REPO_VPS_COUNT[$i]:-0}"
  local vps_st="${REPO_VPS_STATUS[$i]:-}"

  echo ""
  echo -e "  ${C_BOLD}${name}${C_RESET}"
  echo -e "  ${C_DIM}$(printf '%.0s─' $(seq 1 40))${C_RESET}"

  # Mac section
  if [ "$syncable" = "vps-only" ]; then
    echo -e "  ${C_DIM}Mac   · n/a${C_RESET}"
  elif [ "$lc" -eq 0 ] 2>/dev/null; then
    echo -e "  ${C_GREEN}Mac   ● clean${C_RESET}  ${C_DIM}(${REPO_LOCAL_BRANCH[$i]:-})${C_RESET}"
  else
    echo -e "  ${C_YELLOW}Mac   ● ${lc} changes${C_RESET}  ${C_DIM}(${REPO_LOCAL_BRANCH[$i]:-})${C_RESET}"
    echo "${REPO_LOCAL_STATUS[$i]:-}" | head -8 | while IFS= read -r line; do
      [ -n "$line" ] && echo -e "        ${C_DIM}${line}${C_RESET}"
    done
  fi

  # VPS section
  if [ "$vps_st" = "(unreachable)" ]; then
    echo -e "  ${C_RED}VPS   ● offline${C_RESET}"
  elif [ "$vc" -eq 0 ] 2>/dev/null; then
    echo -e "  ${C_GREEN}VPS   ● clean${C_RESET}  ${C_DIM}(${REPO_VPS_BRANCH[$i]:-})${C_RESET}"
  else
    echo -e "  ${C_YELLOW}VPS   ● ${vc} changes${C_RESET}  ${C_DIM}(${REPO_VPS_BRANCH[$i]:-})${C_RESET}"
    echo "$vps_st" | head -8 | while IFS= read -r line; do
      [ -n "$line" ] && echo -e "        ${C_DIM}${line}${C_RESET}"
    done
  fi

  echo ""
}

# ============================
# SYNC OPERATIONS
# ============================
sync_repo() {
  local name="$1" local_dir="$2" vps_dir="$3" branch="$4"

  if [ -z "$local_dir" ]; then
    warn "VPS-only -- skip"
    return 0
  fi
  if [ ! -d "$local_dir/.git" ]; then
    err "Not found: $local_dir"
    return 1
  fi

  if [ -n "$DRY_RUN" ]; then
    local lst vst
    lst=$(cd "$local_dir" && git status --short --ignore-submodules=dirty 2>/dev/null)
    vst=$(vps_git "$name" "$vps_dir" "git status --short --ignore-submodules=dirty 2>/dev/null" || echo "(unreachable)")
    [ -n "$lst" ] && echo -e "  ${C_YELLOW}Mac:${C_RESET}" && echo "$lst" | while read -r l; do echo "      $l"; done || info "Mac: clean"
    [ -n "$vst" ] && ! echo "$vst" | grep -q "unreachable" && echo -e "  ${C_YELLOW}VPS:${C_RESET}" && echo "$vst" | while read -r l; do echo "      $l"; done || info "VPS: clean"
    return 0
  fi

  case "$DIRECTION" in
    push)
      cd "$local_dir"
      if [ -n "$(git status --porcelain --ignore-submodules=dirty)" ]; then
        git add -A
        git commit -m "${COMMIT_MSG:-chore: sync local changes}" --no-verify 2>/dev/null || true
        step "Mac committed"
      fi
      git push origin "$branch" 2>/dev/null && step "Pushed to origin" || info "Already up to date"
      vps_git "$name" "$vps_dir" "git pull --ff-only origin $branch 2>&1" >/dev/null && ok "VPS pulled" || err "VPS pull failed"
      ;;
    pull)
      local vps_msg="${COMMIT_MSG:-chore: sync VPS changes}"
      vps_git "$name" "$vps_dir" "git add -A && git diff --cached --quiet || git commit -m '${vps_msg//\'/\'\\\'\'}' --no-verify 2>/dev/null; git push origin $branch 2>/dev/null || true" >/dev/null
      step "VPS committed & pushed"
      cd "$local_dir"
      git pull --ff-only origin "$branch" 2>/dev/null && ok "Mac pulled" || err "Mac pull failed"
      ;;
    sync)
      sync_both "$name" "$local_dir" "$vps_dir" "$branch"
      ;;
  esac

  # Track synced repo for post-sync hooks
  SYNCED_REPOS+=("$name")
}

# -- Bidirectional sync --
sync_both() {
  local name="$1" local_dir="$2" vps_dir="$3" branch="$4"

  # Step 1: commit + push Mac
  cd "$local_dir"
  if [ -n "$(git status --porcelain --ignore-submodules=dirty)" ]; then
    git add -A
    git commit -m "${COMMIT_MSG:-chore: sync local changes}" --no-verify 2>/dev/null || true
    step "Mac committed"
  fi
  git push origin "$branch" 2>/dev/null && step "Mac pushed" || info "Mac already up to date"

  # Step 2: commit + push VPS
  local vps_push_out
  local vps_msg="${COMMIT_MSG:-chore: sync VPS changes}"
  vps_push_out=$(vps_git "$name" "$vps_dir" "git add -A && git diff --cached --quiet || git commit -m '${vps_msg//\'/\'\\\'\'}' --no-verify 2>/dev/null; git push origin $branch 2>&1 || echo 'PUSH_FAILED'")
  if echo "$vps_push_out" | grep -q "PUSH_FAILED"; then
    # VPS push failed -- likely behind origin. Pull first, then retry.
    step "VPS behind origin, pulling first..."
    vps_git "$name" "$vps_dir" "git pull --rebase origin $branch 2>/dev/null && git push origin $branch 2>/dev/null" >/dev/null \
      && step "VPS rebased & pushed" || err "VPS push conflict -- resolve manually"
  else
    step "VPS committed & pushed"
  fi

  # Step 3: pull both sides
  cd "$local_dir"
  git pull --ff-only origin "$branch" 2>/dev/null && ok "Mac synced" || err "Mac pull failed (merge needed?)"
  vps_git "$name" "$vps_dir" "git pull --ff-only origin $branch 2>&1" >/dev/null && ok "VPS synced" || err "VPS pull failed"
}

# -- Sync all syncable repos bidirectionally --
sync_all() {
  for def in "${REPO_DEFS[@]}"; do
    IFS='|' read -r name local_dir vps_dir branch <<< "$def"
    [ -z "$local_dir" ] && continue
    [ ! -d "$local_dir/.git" ] && continue
    header "$name"
    sync_both "$name" "$local_dir" "$vps_dir" "$branch"
    SYNCED_REPOS+=("$name")
  done
}

# ============================
# NON-INTERACTIVE STATUS
# ============================
show_status() {
  local name="$1" local_dir="$2" vps_dir="$3"
  header "$name"

  if [ -n "$local_dir" ] && [ -d "$local_dir/.git" ]; then
    local lst lc lb
    lst=$(cd "$local_dir" && git status --short --ignore-submodules=dirty 2>/dev/null)
    lc=$(count_changes "$lst"); lb=$(cd "$local_dir" && git branch --show-current 2>/dev/null)
    if [ "$lc" -eq 0 ]; then ok "Mac: clean ($lb)"
    else warn "Mac: $lc changes ($lb)"; echo "$lst" | head -10 | while read -r l; do echo "      $l"; done; fi
  elif [ -n "$local_dir" ]; then info "Mac: not cloned"
  else info "Mac: (VPS-only)"; fi

  local vst vc vb
  vst=$(vps_exec "cd \"$vps_dir\" && git status --short 2>/dev/null" || echo "(unreachable)")
  vc=$(count_changes "$vst"); vb=$(vps_exec "cd \"$vps_dir\" && git branch --show-current 2>/dev/null" || echo "?")
  if echo "$vst" | grep -q "unreachable"; then err "VPS: unreachable"
  elif [ "$vc" -eq 0 ]; then ok "VPS: clean ($vb)"
  else warn "VPS: $vc changes ($vb)"; echo "$vst" | head -10 | while read -r l; do echo "      $l"; done; fi
}

# ==========================================
# INTERACTIVE MODE
# ==========================================

if [ -n "$INTERACTIVE" ]; then
  if ! command -v fzf &>/dev/null; then
    err "fzf required: brew install fzf"; exit 1
  fi

  while true; do
    REPO_NAMES=(); REPO_LOCAL_DIRS=(); REPO_VPS_DIRS=(); REPO_BRANCHES=()
    REPO_LOCAL_STATUS=(); REPO_VPS_STATUS=()
    REPO_LOCAL_BRANCH=(); REPO_VPS_BRANCH=()
    REPO_LOCAL_COUNT=(); REPO_VPS_COUNT=(); REPO_SYNCABLE=()

    collect_status

    fzf_items=""
    # "Sync All" entry at the top (padded to match columns)
    local sync_all_label
    sync_all_label=$(printf "  %-18s\033[38;5;111m%-10s  %-10s\033[0m" ">> Sync All" "" "")
    fzf_items+="$sync_all_label"$'\n'
    for i in "${!REPO_NAMES[@]}"; do
      line=$(status_line "$i")
      [ -n "$line" ] && fzf_items+="$line"$'\n'
    done
    fzf_items="${fzf_items%$'\n'}"
    [ -z "$fzf_items" ] && { err "No repos found"; exit 1; }

    clear
    echo -e ""
    echo -e "  ${C_BOLD}Sync VPS${C_RESET}  ${C_DIM}enter select  esc quit${C_RESET}"
    echo ""

    chosen=$(printf '%s\n' "$fzf_items" | fzf \
      --ansi \
      --no-multi \
      --height=~16 \
      --reverse \
      --no-info \
      --no-preview \
      --header=$'    REPO              Mac       VPS' \
      --prompt="  " \
      --pointer="›" \
      --color="fg:7,fg+:15,bg+:236,hl:111,hl+:111,pointer:111,prompt:111,header:8,border:8" \
      --border=rounded \
      --margin=0,2 \
    ) || break

    # Handle "Sync All" selection
    if echo "$chosen" | grep -q "Sync All"; then
      clear
      echo -e "\n  ${C_BOLD}${C_CYAN}>> Sync All${C_RESET}\n"
      sync_all
      post_sync_telegram
      echo ""
      echo -e "  ${C_DIM}press any key${C_RESET}"
      SYNCED_REPOS=()
      read -r -n 1 -s
      continue
    fi

    repo_name=$(echo "$chosen" | awk '{print $1}')
    repo_idx=-1
    for i in "${!REPO_NAMES[@]}"; do
      [ "${REPO_NAMES[$i]}" = "$repo_name" ] && repo_idx=$i && break
    done
    [ "$repo_idx" -eq -1 ] && continue

    # Detail + action menu
    clear
    show_detail "$repo_idx"

    syncable="${REPO_SYNCABLE[$repo_idx]:-}"
    local_count="${REPO_LOCAL_COUNT[$repo_idx]:-0}"
    vps_count="${REPO_VPS_COUNT[$repo_idx]:-0}"
    has_local_changes=false; [ "$local_count" -gt 0 ] 2>/dev/null && has_local_changes=true
    has_vps_changes=false; [ "$vps_count" -gt 0 ] 2>/dev/null && has_vps_changes=true

    actions=""
    if [ "$syncable" = "yes" ] || [ "$syncable" = "no" ]; then
      if $has_local_changes || $has_vps_changes; then
        actions+="⇄  Sync both ways"$'\n'
        actions+="↑  Push  Mac → VPS"$'\n'
      fi
      actions+="↓  Pull  VPS → Mac"$'\n'
      if $has_local_changes; then
        actions+="✗  Discard local changes"$'\n'
      fi
      if $has_vps_changes; then
        actions+="✗  Discard VPS changes"$'\n'
      fi
    fi
    if [ "$syncable" = "vps-only" ] && $has_vps_changes; then
      actions+="↑  Commit & push VPS"$'\n'
      actions+="✗  Discard VPS changes"$'\n'
    fi
    actions+="←  Back"

    action=$(printf '%s\n' "$actions" | fzf \
      --ansi \
      --no-multi \
      --height=~10 \
      --reverse \
      --no-info \
      --no-preview \
      --prompt="  " \
      --pointer="›" \
      --color="fg:7,fg+:15,bg+:236,hl:111,hl+:111,pointer:111,prompt:111,header:8,border:8" \
      --border=rounded \
      --margin=0,2 \
    ) || continue

    name="${REPO_NAMES[$repo_idx]}"
    local_dir="${REPO_LOCAL_DIRS[$repo_idx]:-}"
    vps_dir="${REPO_VPS_DIRS[$repo_idx]:-}"
    branch="${REPO_BRANCHES[$repo_idx]:-main}"

    echo ""
    echo -e "  ${C_DIM}$(printf '%.0s─' $(seq 1 40))${C_RESET}"

    case "$action" in
      *"Sync both"*)
        sync_both "$name" "$local_dir" "$vps_dir" "$branch"
        SYNCED_REPOS+=("$name")
        post_sync_telegram
        SYNCED_REPOS=()
        ;;
      *"Push"*"Mac"*)
        DIRECTION="push"
        sync_repo "$name" "$local_dir" "$vps_dir" "$branch"
        post_sync_telegram
        SYNCED_REPOS=()
        ;;
      *"Pull"*"VPS"*)
        DIRECTION="pull"
        sync_repo "$name" "$local_dir" "$vps_dir" "$branch"
        post_sync_telegram
        SYNCED_REPOS=()
        ;;
      *"Commit & push VPS"*)
        local vps_msg="${COMMIT_MSG:-chore: sync VPS changes}"
        vps_exec "cd \"$vps_dir\" && git add -A && git diff --cached --quiet || git commit -m '${vps_msg//\'/\'\\\'\'}' --no-verify 2>/dev/null; git push origin $branch 2>/dev/null || true" >/dev/null
        ok "VPS committed & pushed"
        ;;
      *"Discard VPS"*)
        echo -e "  ${C_RED}Discard all VPS changes?${C_RESET}"
        read -r -p "  Type 'yes': " confirm
        if [ "$confirm" = "yes" ]; then
          vps_exec "cd \"$vps_dir\" && git checkout . && git clean -fd" >/dev/null
          ok "VPS changes discarded"
        else info "Cancelled"; fi
        ;;
      *"Discard local"*)
        echo -e "  ${C_RED}Discard all local changes?${C_RESET}"
        read -r -p "  Type 'yes': " confirm
        if [ "$confirm" = "yes" ]; then
          cd "$local_dir" && git checkout . && git clean -fd
          ok "Local changes discarded"
        else info "Cancelled"; fi
        ;;
      *"Back"*) continue ;;
    esac

    echo ""
    echo -e "  ${C_DIM}press any key${C_RESET}"
    read -r -n 1 -s
  done

  echo ""
  exit 0
fi

# ==========================================
# POST-SYNC: Telegram command registration
# ==========================================

post_sync_telegram() {
  # Determine which agents need Telegram command refresh
  local agents_to_refresh=()
  local refresh_all=false

  for mapping in "${SKILL_REPO_MAP[@]}"; do
    IFS='|' read -r repo agent_id <<< "$mapping"
    for synced in "${SYNCED_REPOS[@]}"; do
      if [ "$synced" = "$repo" ]; then
        if [ "$agent_id" = "all" ]; then
          refresh_all=true
          break 2
        fi
        agents_to_refresh+=("$agent_id")
      fi
    done
  done

  if [ ${#agents_to_refresh[@]} -eq 0 ] && ! $refresh_all; then
    return 0
  fi

  header "Telegram commands sync"
  local register_script="/home/node/shared-skills/telegram-sync/scripts/register_commands.py"
  local vps_args="--quiet"
  [ -n "$DRY_RUN" ] && vps_args="--dry-run"

  if $refresh_all; then
    local result
    result=$(vps_exec "python3 $register_script $vps_args 2>&1") || true
    if [ -n "$result" ]; then
      echo "$result" | while IFS= read -r line; do [ -n "$line" ] && echo -e "  ${C_CYAN}${line}${C_RESET}"; done
    else
      ok "All agents up to date"
    fi
  else
    for agent_id in "${agents_to_refresh[@]}"; do
      local result
      result=$(vps_exec "python3 $register_script $agent_id $vps_args 2>&1") || true
      if [ -n "$result" ]; then
        echo "$result" | while IFS= read -r line; do [ -n "$line" ] && echo -e "  ${C_CYAN}${line}${C_RESET}"; done
      else
        ok "$agent_id: up to date"
      fi
    done
  fi
}

# ==========================================
# NON-INTERACTIVE MODE
# ==========================================

if [ -n "$STATUS_ONLY" ]; then
  echo -e "\n${C_BOLD}${C_BLUE}  Status: Mac + VPS${C_RESET}"
elif [ -n "$DRY_RUN" ]; then
  echo -e "\n${C_BOLD}${C_BLUE}  Dry run${C_RESET}"
elif [ "$DIRECTION" = "push" ]; then
  echo -e "\n${C_BOLD}${C_GREEN}  Push: Mac → VPS${C_RESET}"
elif [ "$DIRECTION" = "sync" ]; then
  echo -e "\n${C_BOLD}${C_CYAN}  Sync: Mac ⇄ VPS${C_RESET}"
else
  echo -e "\n${C_BOLD}${C_YELLOW}  Pull: VPS → Mac${C_RESET}"
fi

for def in "${REPO_DEFS[@]}"; do
  IFS='|' read -r name local_dir vps_dir branch <<< "$def"

  if [ ${#SELECTED[@]} -gt 0 ]; then
    found=0
    for s in "${SELECTED[@]}"; do [ "$s" = "$name" ] && found=1 && break; done
    [ "$found" -eq 0 ] && continue
  fi

  if [ -n "$STATUS_ONLY" ]; then
    show_status "$name" "$local_dir" "$vps_dir"
  else
    if [ -z "$local_dir" ] && [ ${#SELECTED[@]} -eq 0 ]; then continue; fi
    header "$name"
    sync_repo "$name" "$local_dir" "$vps_dir" "$branch"
  fi
done

# Post-sync: register new Telegram commands if skill repos were synced
if [ -z "$STATUS_ONLY" ] && [ ${#SYNCED_REPOS[@]} -gt 0 ]; then
  post_sync_telegram
fi

echo -e "\n  ${C_GREEN}${C_BOLD}Done${C_RESET}\n"
