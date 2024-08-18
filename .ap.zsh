export AUTOPILOT_PATH=/home/andrei-local/devel/ap

alias bssq='cd "$(git rev-parse --show-toplevel)" && tools/autopilot ssq-build optimus-hw4-dev --no-strip --dest my_ssq.ssq'
alias b86='cd "$(git rev-parse --show-toplevel)" && tools/autopilot build optimus_4 --no-strip -x86 --enable_replay_build --enable_synchronous_scheduler_in_replay'
alias boverlay='tools/autopilot build optimus_4 --no-strip //:overlays'

