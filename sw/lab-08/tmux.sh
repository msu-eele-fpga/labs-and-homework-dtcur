#!/bin/bash

#Session name
SESSION="FGPA"
#Check for session
SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

if [ "$SESSIONEXISTS" = "" ]
then 
	tmux new-session -d -s $SESSION 

	#Create window and start 
	tmux rename-window -t 0 'CWD'
	tmux send-keys -t 'CWD' 'zsh' C-m 'clear' C-m
	
	tmux new-widnow -t  $SESSION:1 -n 'UART'
	tmux send-keys -t 'UART' 'sudo minicom -D /dev/ttyUSB0' C-m
	
	tmux new-window -t $session:2 -n 'SSH'
	tmux send-keys -t 'SSH' 'kitten ssh soc@192.168.0.10' C-m
fi
#Attach to session
tmux attach-session -t $SESSION:0
