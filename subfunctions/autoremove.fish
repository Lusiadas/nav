# Check for invalid bookmarks
set -l bookmarks
for bookmark in (command find $_nav_bookmarks -type l 2>/dev/null)
  string match -qr '(^/media/|.*/mtp:.*)' (command readlink $bookmark | string escape)
  and continue
  test -d "$bookmark"
  and continue
  set --append bookmarks $bookmark
end

# Autoremove bookmarks
if test -z "$bookmarks"
  win "All bookmarks are valid"
  exit 0
end
command rm $bookmarks
set bookmarks (string match -r "(?<=$nav_bookmarks/).+" $bookmarks)
test (count $bookmarks) -eq 1
and set bookmarks " |$bookmarks|"
or set bookmarks "s |"(string join '|, |' $bookmarks)"|,"
win "Bookmark$bookmarks removed."
