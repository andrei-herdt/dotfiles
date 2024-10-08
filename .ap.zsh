export AUTOPILOT_PATH=~/devel/ap
PATH=$PATH:~/devel/ext4fuse

alias bssq='cd "$(git rev-parse --show-toplevel)" && tools/autopilot ssq-build optimus-hw4-dev --no-strip --dest my_ssq.ssq'
alias b86='cd "$(git rev-parse --show-toplevel)" && tools/autopilot build optimus_4 --no-strip -x86 --enable_replay_build --enable_synchronous_scheduler_in_replay'
alias boverlay='tools/autopilot build optimus_4 --no-strip //:overlays'

function robot-auth {
    ROBOT_ID=$(ssh $1 echo 2>&1 | grep tesla:robotics:opt4 | head -1 | sed 's/.*:\([a-zA-Z0-9-]*\).*/\1/')
    shift
    ssh-cert -d opt4 "$ROBOT_ID" "$@"
}

