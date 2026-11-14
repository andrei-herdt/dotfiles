# dl: copy local files to a remote workstation with scp.
# Sourced from ~/.zshrc; installed to ~/.zsh/dl.zsh by `install.bash` (zsh option).
#
# Machine-specific settings go in ~/.zshrc.local (never committed):
#   DL_HOST=user@my-workstation     # required
#   DL_DIR=data/                    # optional, remote dir (default: remote $HOME)
#
# Usage:
#   dl **<Tab>      fzf picker (fzf completion trigger); Tab multi-selects, Enter inserts paths
#   dl              same picker, then sends right away
#   dl -l           send the most recent download
#   dl <names>      existing paths are used as-is, otherwise looked up in ~/Downloads
# `ws` is an alias for ssh-ing to the same host.

[[ -n $DL_HOST ]] && alias ws="ssh $DL_HOST"

# Candidate files as "name<TAB>dim dir<TAB>full path": ~/Downloads first
# (newest first), then the rest of ~ (hidden dirs, Library, node_modules skipped).
_dl_list() {
  { ls -t ~/Downloads/*(.N) 2>/dev/null
    find ~ -maxdepth 5 \( -path ~/Downloads -o -path ~/Library -o -path '*/.*' -o -name node_modules \) -prune -o -type f -print 2>/dev/null
  } | awk -v h="$HOME" '!seen[$0]++ { n=$0; sub(".*/","",n); d=$0; sub("/[^/]*$","",d); sub("^" h,"~",d);
                                      printf "%s\t\033[2m%s\033[0m\t%s\n", n, d, $0 }'
}

# fzf options: show name + dir, search the name only, return the full path
_dl_fzf_opts=(--multi --no-sort --tiebreak=index --ansi
              --delimiter=$'\t' --with-nth=1,2 --nth=1 --accept-nth=3
              --prompt='send> ' --header='Tab: multi-select, Enter: confirm'
              --preview 'ls -lh {3}' --preview-window=down:2)

# `dl **<Tab>` -- hook into fzf's zsh completion (needs `fzf --zsh` / the omz fzf plugin)
_fzf_complete_dl() {
  _fzf_complete "${_dl_fzf_opts[@]}" -- "$@" < <(_dl_list)
}
_fzf_complete_dl_post() {
  local p; while IFS= read -r p; do print -r -- "${(q)p}"; done
}

# plain `dl <Tab>` completes file names from ~/Downloads
_dl() { _files -W ~/Downloads }
(( $+functions[compdef] )) && compdef _dl dl

dl() {
  [[ -n $DL_HOST ]] || { echo "dl: set DL_HOST (e.g. user@host) in ~/.zshrc.local" >&2; return 1; }
  local dest="$DL_HOST:${DL_DIR:-}"
  local -a files
  if [[ $1 == -l ]]; then
    files=(~/Downloads/*(.om[1]))
  elif (( $# == 0 )); then
    command -v fzf >/dev/null || { echo "dl: fzf not installed" >&2; return 1; }
    files=("${(@f)$(_dl_list | fzf "${_dl_fzf_opts[@]}")}")
    [[ -z ${files[1]} ]] && return 1
  else
    local f; for f in "$@"; do
      [[ -e $f ]] && files+=("$f") || files+=("$HOME/Downloads/${f:t}")
    done
  fi
  print -P "%F{cyan}->%f ${files[@]:t} => $dest"
  scp "${files[@]}" "$dest"
}
