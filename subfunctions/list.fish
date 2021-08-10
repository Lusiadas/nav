# Test argument validity
set argv $_nav_bookmarks/{$argv}
set -l failed
for i in (command seq (count $argv))
  test -d $argv[$i]
  and  continue
  err "nav: $argv[$i]: Bookmark folder not found"
  set --erase argv[$i]
  set failed true
end

# Print contents of listed folders
test "$argv"
or set argv $_nav_bookmarks
for folder in $argv
  test (count $argv) -gt 1
  and echo (set_color --bold blue)(command basename $folder)(set_color normal)
  command tree -C $folder \
  | command tail +2 \
  | command head -n -1
end
test -z "$failed"