argparse s r m a y -- $argv
if set --query _flag_s
    source $_nav_subfunctions/save.fish $_flag_y $argv
else if set --query _flag_r
    source $_nav_subfunctions/remove.fish $_flag_y $argv
else if set --query _flag_m
    source $_nav_subfunctions/move.fish $_flag_y $argv
else
    source $_nav_subfunctions/autoremove.fish
end

# Erase emptied folders in the bookmark directory
for folder in (command find $_nav_bookmarks -type d 2>/dev/null)
    ls $folder | string length -q
    or command rm -fr $folder
end
