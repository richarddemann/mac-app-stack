#!/bin/bash
set -euo pipefail

stack_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
catalog="$stack_dir/catalog.tsv"
mode=""
install=0
output="$PWD/Brewfile.selected"

while (($#)); do
  case "$1" in
    --all|--research|--development|--utilities|--choose|--list)
      if [[ -n "$mode" ]]; then echo "Choose one selection mode." >&2; exit 2; fi
      mode="${1#--}"
      ;;
    --install) install=1 ;;
    --output)
      shift
      if (($# == 0)); then echo "--output needs a path." >&2; exit 2; fi
      output="$1"
      ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

if [[ -z "$mode" ]]; then
  printf 'Choose: 1) everything  2) research  3) development  4) utilities  5) individual apps\n'
  read -r answer
  case "$answer" in
    1) mode=all ;; 2) mode=research ;; 3) mode=development ;;
    4) mode=utilities ;; 5) mode=choose ;;
    *) echo "No selection made." >&2; exit 2 ;;
  esac
fi

if [[ "$mode" == list ]]; then
  column -s $'\t' -t "$catalog"
  exit 0
fi

selected=()
while IFS=$'\t' read -r category name source identifier tap <&3; do
  [[ "$category" == category ]] && continue
  include=0
  case "$mode" in
    all) include=1 ;;
    research|development|utilities)
      [[ "$category" == "$mode" ]] && include=1 ;;
    choose)
      printf 'Include %-25s (%s)? [y/N] ' "$name" "$category"
      read -r answer
      [[ "$answer" == y || "$answer" == Y ]] && include=1 ;;
  esac
  if ((include)); then selected+=("$category|$name|$source|$identifier|$tap"); fi
done 3< "$catalog"

if ((${#selected[@]} == 0)); then
  echo "No apps selected." >&2
  exit 1
fi
if [[ -e "$output" ]]; then
  echo "Won't overwrite $output; choose a different --output path." >&2
  exit 1
fi

{
  echo '# Generated from this stack. Review before installing.'
  taps=''
  for row in "${selected[@]}"; do
    IFS='|' read -r category name source identifier tap <<< "$row"
    if [[ "$tap" != - && " $taps " != *" $tap "* ]]; then
      printf 'tap "%s"\n' "$tap"
      taps="$taps $tap"
    fi
  done
  for row in "${selected[@]}"; do
    IFS='|' read -r category name source identifier tap <<< "$row"
    case "$source" in
      cask) printf 'cask "%s" # %s (%s)\n' "$identifier" "$name" "$category" ;;
      mas) printf 'mas "%s", id: %s # %s\n' "$name" "$identifier" "$category" ;;
      *) echo "Unknown source for $name: $source" >&2; exit 2 ;;
    esac
  done
} > "$output"

printf 'Saved %s app(s) to %s\n' "${#selected[@]}" "$output"
if ((install)); then
  if ! command -v brew >/dev/null 2>&1; then
    echo 'Install Homebrew first: https://brew.sh/' >&2
    exit 1
  fi
  brew bundle install --no-upgrade --file="$output"
else
  echo "To install later: brew bundle install --no-upgrade --file=\"$output\""
fi
