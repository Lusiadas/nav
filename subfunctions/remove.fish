argparse y -- $argv

# Delete the navigation history, if such is the command
if contains history $argv
  if not set --query _flag_y
    if read -p 'wrn "Delete navigation history? [y/n]: "' \
    | string match -qi y
      rm -r $_nav_history
      win "History deleted"
    end
  end
  set --erase argv[(contains -i history $argv)]
  test "$argv"
  or exit 0
end

# Delete the bookmarks folder, if such is the command
if contains all $argv
    if not set --query _flag_y
        read -n 1 -p 'wrn "Delete all bookmarks? [y/n]: "' \
        | string match -qi y
        or exit 1
  end
  command rm -fr "$_nav_bookmarks"
  win "Bookmarks deleted"
  exit 0
end

# Delete bookmarks or folders
set -l bookmarks;
set -l folders;
for arg in $argv
    if test -L "$_nav_bookmarks/$arg"
        set bookmarks $bookmarks $arg
    else if test -d "$_nav_bookmarks/$arg"
        set folders $folders $arg
    else
        err "nav: Neighter bookmarks nor folders were found for |$arg|"
        continue
  end
  command rm -fr "$_nav_bookmarks/$arg"
end

# Reply if bookmarks or folders were deleted.
if test -z "$folders" -a -z "$bookmarks"
    reg "Use |nav -l| to see available bookmarks"
    exit 1
end
if test -n "$bookmarks"
    test (count $bookmarks) -gt 1
    and set bookmarks 's |'(string join '|, |' $bookmarks)'|,'
    or set bookmarks " |$bookmarks|"
end
if test -n "$folders"
    test (count $folders) -gt 1
    and set folders 's |'(string join '|, |' $folders)'|,'
    or set folders " |$folders|"
end
if test -z "$folders"
    win "Bookmark$bookmarks removed."
else if test -z "$bookmarks"
    win "Folder$folders removed."
else
    win "Bookmark$bookmarks and folder$folders removed."
end
