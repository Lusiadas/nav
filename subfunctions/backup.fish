argparse y -- $argv

# Restoring a bookmarks folder from a file
if string match -q restore $argv[1]
  if test -z "$argv[2]"
    set -l backup (ls | string match -ar '.+\.bak$')
    if test -z "$backup"
      err "nav: No target backup file was specified, nor could be found in the current directory"
      exit 1
    end
    if test (count $backup) -gt 1
      wrn "More than one backup file found in the current folder"
      for i in (seq (count $backup))
        reg "$i. $backup[$i]"
      end
      reg (math (count $backup) + 1)". all"
      read -P "Use which? [number/[c]ancel]: " opt
      test "$opt" -le (math (count $backup) + 1)
      or exit 1
      test "$opt" -le (count $backup)
      and set --append argv $backup[$opt]
      or set --append argv $backup
    else
      set --append argv $backup
    end
  else
    for i in (command seq (count $argv) 2)
      test -f $argv[$i]
      or continue
      reg "File |$backup[$i]| not found"
      set --erase argv[$i]
    end
    string match -qv restore $argv
    or exit 1
  end
  set -l bookmarks
  for arg in $argv[2..-1]
    set --append bookmarks (sed '/^#/ d' $arg \
    | sed -r 's/([^\])\s/\1\n/g')
  end
  source $_nav_functions/save.fish $_flag_y $bookmarks

#Saving a backup into a file
else
  set -l bookmarks (find $_nav_bookmarks -type l 2>/dev/null \
  | string match -r -- "(?<=$_nav_bookmarks/).+")
  if test "$argv[2]"
    source $_nav_functions/instructions.fish "nav -b/--backup"
    exit 1
  else if not string length -q $bookmarks
    err "nav: There are no bookmarks available to backup"
    exit 1
  else if test -z "$argv"
    set argv "bookmarks.bak"
  else if test -d "$argv"
    set argv "$argv/bookmarks.bak"
  end
  if test -e "$argv"
    if not set --query _flag_y
      read -n 1 -p "wrn \"File |$argv| already exists. Overwrite? [y/n]: \"" \
      | string match -qi y
      or exit 1
    end
  end
  command mkdir -p (command dirname $argv)
  echo "# Bookmark list generated with nav" > $argv
  for bookmark in $bookmarks
    echo $bookmark (command readlink "$nav_bookmarks/$bookmark" \
    | string escape) >> $argv
  end
  win "Bookmarks backup saved at |$argv|"
end
