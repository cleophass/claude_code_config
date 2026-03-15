#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Git branch only
git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)

# ANSI colors
BLUE='\033[0;36m'
WHITE='\033[0;37m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

SEP=" | "

# --- Line 1: [model] | cwd | emoji git-branch ---
printf -v line1 "${BLUE}[%s]${RESET}" "$model"
line1="${line1}${SEP}📁 ${WHITE}$(basename "$cwd")${RESET}"
if [ -n "$git_branch" ]; then
  line1="${line1}${SEP}🎋 ${WHITE}${git_branch}${RESET}"
fi

# --- Line 2: green progress bar ---
if [ -z "$used" ]; then
  line2="Context: no data yet"
else
  used_int=$(printf "%.0f" "$used")

  bar_length=15
  filled=$(( used_int * bar_length / 100 ))
  empty=$(( bar_length - filled ))

  bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done

  printf -v line2 "${GREEN}%s${RESET}  ${WHITE}%d%%%s" "$bar" "$used_int" "$RESET"
fi

printf "%b\n%b" "$line1" "$line2"
