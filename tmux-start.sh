#!/bin/bash


session=robohive
tmux new-session -d -s $session
tmux send-keys -t $session:1 'cd ~/devel/robohive' C-m
tmux split -h -t $session:1
tmux send-keys -t $session:1 'cd ~/devel/robohive/docker' C-m

session=robohive2
tmux new-session -d -s $session
tmux send-keys -t $session:1 'cd ~/devel/robohive2' C-m
tmux split -h -t $session:1
tmux send-keys -t $session:1 'cd ~/devel/robohive2/docker' C-m

tmux attach-session -t $session

