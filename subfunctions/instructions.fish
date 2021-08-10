set -l bld (set_color 00afff -o)
set -l reg (set_color normal)
set -l instructions $bld"nav - Navigational Assistance with Velocity

"$bld"DESCRIPTION

In brief, it finds a folder whose name matches search patterns and makes it the current working directory. Ambiguities prompt the user to choose a directory from a list ordered on the basis of folders that have been used most often and most recently.

"$bld"NAVIGATION OPTIONS

"$bld"nav "$reg"[pattern] ...
If no argument is provided, list bookmarks. Otherwise, look for a directory in the navigation history that matches the patterns given and go there.

"$bld"nav -w/--where"$reg" [pattern] ...
Go to a directory in the navigation history.

"$bld"nav -t/--to"$reg" [pattern] ...
Go to a bookmarked directory. If a matching bookmarked directory is not found, fallback to "$bld"--where"$reg" option.

"$bld"nav -f/--foward"$reg" [pattern] ...
Go to the closest child folder that matches passed patterns.

"$bld"nav -b/--back"$reg" [pattern] ...
Go to the closest parent folder that matches passed patterns.

"$bld"NAVIGATION MODIFIER OPTIONS"$reg"

"$bld"nav [-t/-w/-f/-b] -p/--print"$reg" [pattern] ...
Print destination instead.

"$bld"nav [-t/-w/-f/-b] -c/--commander"$reg" [first pattern] [, second pattern]
Open directory using mc, a.k.a. the Midnight Commander. A directory can be opened for each panel by dividing search patterns using ','.

"$bld"BOOKMARKING OPTIONS

"$bld"nav -s/--save"$reg" [name] [destination] ...
Bookmark directories. If only a name is provided, the current directory is bookmarked.

"$bld"nav -r/--remove"$reg" [bookmark/all/history] ...
Erase some, or all, bookmarks and bookmark folders, or the navigation history.

"$bld"nav -m/--move"$reg" [source] ... [destination]
Move or rename bookmarks or bookmark folders.

"$bld"nav -a/--autoremove"$reg"
Remove bookmarks of folders that no longer exist. Bookmarks with destinations starting with /media will be ignored.

"$bld"nav -l/--list"$reg" [folder]
List the contents of the bookmarks folder or some inner folders.

"$bld"nav -d/--backup"$reg" [restore] [file]
Create, or restore from, a backup file containing all bookmarks. If no file is specified, it'll create, or look for, a backup file in the current folder.

"$bld"MISC"$reg"

"$bld"nav -x/--abbr"$reg"
Add, or otherwise remove, recommended abbreviations for iteractive use:

"$bld"w"$reg" for "$bld"nav --where"$reg"
"$bld"t"$reg" for "$bld"nav --to"$reg"
"$bld"f"$reg" for "$bld"nav --foward"$reg"
"$bld"b"$reg" for "$bld"nav --back"$reg"
"$bld"n"$reg" for "$bld"nextd"$reg"
"$bld"p"$reg" for "$bld"prevd"$reg"
"$bld"l"$reg" for "$bld"nav --list"$reg"

"$bld"nav -h/--help"$reg"
Display these instructions.
"
switch "$argv"
  case '*x/--\S+'
    echo $instructions | grep -A 9 -E "$argv" 1>&2
  case '*/--\S+'
    echo $instructions | grep -A 1 -E "$argv" 1>&2
  case ''
    echo $instructions | less -R
end
