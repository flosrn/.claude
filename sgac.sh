#!/bin/zsh

# ====================================
# SMART GIT AUTO COMMIT with AI
# ====================================

# Smart Git Auto Commit avec gh-copilot
sgac() {
  echo "🚀 Smart Git Auto Commit"

  # Stage tous les changements
  git add .

  # Vérifier s'il y a des changements
  local staged_files=$(git diff --cached --name-only)
  if [[ -z "$staged_files" ]]; then
    echo "❌ Aucun changement à committer"
    return 1
  fi

  echo "📁 Fichiers modifiés:"
  echo "$staged_files" | sed 's/^/  • /'

  # Analyse automatique
  echo "🔄 Analyse automatique..."

  local emoji=""
  local type=""
  local scope=""

  # Détecter le type et l'emoji basé sur les fichiers
  if echo "$staged_files" | grep -q "README\|\.md$"; then
    emoji="📚"
    type="docs"
  elif echo "$staged_files" | grep -q "test\|spec\|\.test\.\|\.spec\."; then
    emoji="🧪"
    type="test"
  elif echo "$staged_files" | grep -q "package\.json\|yarn\.lock\|Gemfile\|requirements\.txt"; then
    emoji="🔧"
    type="chore"
  elif echo "$staged_files" | grep -q "\.css$\|\.scss$\|\.less$\|\.styl"; then
    emoji="💄"
    type="style"
  else
    # Analyser le contenu des changements
    local diff_content=$(git diff --cached)
    local new_files=$(git diff --cached --name-status | grep "^A" | wc -l | tr -d ' ')

    if [[ $new_files -gt 0 ]]; then
      emoji="✨"
      type="feat"
    elif echo "$diff_content" | grep -q "^+.*function\|^+.*def\|^+.*class\|^+.*export"; then
      emoji="✨"
      type="feat"
    elif echo "$diff_content" | grep -q "fix\|bug\|error\|Fix\|Bug\|Error"; then
      emoji="🐛"
      type="fix"
    else
      emoji="♻️"
      type="refactor"
    fi
  fi

  # Détecter le scope
  local main_dir=$(echo "$staged_files" | head -1 | cut -d'/' -f1)
  if [[ "$main_dir" != *"."* && -d "$main_dir" && "$main_dir" != "$staged_files" ]]; then
    scope="($main_dir)"
  fi

  # Générer description
  local file_count=$(echo "$staged_files" | wc -l | tr -d ' ')
  local desc="update"
  if [[ $file_count -eq 1 ]]; then
    local basename_file=$(basename "$(echo "$staged_files" | head -1)")
    if [[ $new_files -gt 0 ]]; then
      desc="add $basename_file"
    else
      desc="update $basename_file"
    fi
  else
    desc="update $file_count files"
  fi

  local commit_msg="$emoji $type$scope: $desc"
  echo "📝 Message généré: $commit_msg"

  echo -n "Committer avec ce message ? (y/n): "
  read answer
  if [[ $answer =~ ^[Yy]$ ]]; then
    git commit -m "$commit_msg"
    echo "✅ Commit effectué!"
  else
    echo "❌ Commit annulé"
  fi
}

# Alias rapide
alias gac="sgac"