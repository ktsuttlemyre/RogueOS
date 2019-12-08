





#https://www.youtube.com/watch?v=8-S0cWnLBKg&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf&index=2
#https://github.com/FortAwesome/Font-Awesome/releases
#get TTF
set $RogueHome 
set $workspace "1: Editor"
set $workspace "2: Editor"
set $workspace "3: Editor"
set $workspace "4: Editor"
set $workspace "5: Editor"

bindsym $mod+1 workspace $workspace1

#config
https://faq.i3wm.org/question/3747/enabling-multimedia-keys/?answer=3759#post-id-3759
feh --bg-scale

exec $RogueHome/startup.sh
exec_always $RogueHome/windowManager.sh



#xprop to get class
assign [class="FireFox"] $workspace10


hide_edge_borders both
