# Declare variables
set -l opts t to w where f forward b back p prevd n nextd e echo c commander s save r remove m move l list a autoremove h help d backup x abbr
set -l cmd (command basename (status -f) | command cut -f 1 -d '.')

# Load dependency
source -- $_nav_subfunctions/dependency.fish

# Add options descriptions

complete -fc $cmd -n "not contains_opts (string match -rv -- '^(e|echo|c|commander)\$' $opts)" \
-s t -l to -d 'Go to a bookmarked directory'

complete -fc $cmd -n "not contains_opts (string match -rv -- '^(e|echo|c|commander)\$' $opts)" \
-s w -l where -d 'Go to a directory in the navigation history'

complete -c $cmd -n "not contains_opts (string match -rv -- '^(e|echo|c|commander)\$' $opts)" \
-s f -l forward -d 'Go to a child directory'

complete -fc $cmd -n "not contains_opts (string match -rv -- '^(e|echo|c|commander)\$' $opts)" \
-s b -l back -d 'Go to a parent directory'

complete -rc $cmd -n "not contains_opts (string match -rv -- '^(e|echo|c|commander)\$' $opts)" \
-s p -l prevd -d "Go to a previous directory"

complete -rc $cmd -n "not contains_opts (string match -rv -- '^(e|echo|c|commander)\$' $opts)" \
-s n -l nextd -d "Go to a following directory"

complete -c $cmd -n "not contains_opts (string match -rv -- '^(t|to|w|where|f|forward|b|back)\$' "\
"$opts)" -s e -l echo -d 'Print destination instead'

complete -c $cmd -n "not contains_opts (string match -rv -- '^(t|to|w|where|f|forward|b|back)\$' "\
"$opts)" -s c -l commander -d 'Open with midnight manager'

complete -c $cmd -n "not contains_opts (string match -rv -- '^(t|to|w|where|f|forward|b|back)\$' "\
"$opts)" -s R -l Ranger -d 'Open with ranger'

complete -rc $cmd -n 'not contains_opts' -s s -l save -d 'Bookmark directory'

complete -fc $cmd -n 'not contains_opts' -s r -l remove -d 'Remove bookmark'

complete -fc $cmd -n 'not contains_opts' -s m -l move -d 'Move or rename bookmarks and bookmark '\
'folders'

complete -fc $cmd -n 'not contains_opts' -s l -l list -d 'List bookmarks'

complete -fc $cmd -n 'not contains_opts' -s a -l autoremove -d 'Remove bookmarks of directories '\
'that no longer exist'

complete -rc $cmd -n 'not contains_opts' -s d -l backup -d 'Save bookmarks into, or restore them '\
'from, a file'

complete -c $cmd -n 'contains_opts d backup' -a 'restore' -d 'Restore bookmarks from a file'

complete -fc $cmd -n 'not contains_opts' -s x -l abbr -d 'Add, or remove, abbreviations for '\
'interactive use'

complete -fc $cmd -n 'not contains_opts' -s h -l help -d 'Display instructions'

# List bookmarks
if set -l bookmarks (command find $_nav_bookmarks -type l 2>/dev/null \
| string match -r "(?<=$_nav_bookmarks/).+")
  complete -c $cmd -n 'contains_opts r remove' -a 'all' -d \
  'Delete all bookmarks'
  complete -c $cmd -n 'contains_opts r remove' -a 'history' -d \
  'Delete the navigation history'
  for bookmark in $bookmarks
    set -l path (command readlink "$_nav_bookmarks/$bookmark")
    complete -fc $cmd -n 'contains_opts t to r remove m move' -a "$bookmark" -d "$path"
    complete -rc $cmd -n 'contains_opts s save' -a "$bookmark" -d "$path"
  end
end

# List folders
if set -l folders (command find $_nav_bookmarks -type d -printf '%P\n' 2>/dev/null)
  for folder in $folders
    set -l contents (ls "$_nav_bookmarks/$folder")
    complete -fc $cmd -n 'contains_opts r remove m move l list' -a "$folder" -d "$contents"
  end
end

# List history entries
for path in (sort -u $_nav_history 2>/dev/null)
  complete -fc $cmd -n 'contains_opts w where' -a "$path"
end

# List parent folders
for i in (command seq (string match -ar / $PWD | wc -l))
  string match -r "([^/]*/){$i}" $PWD | read -l path
  complete -fc $cmd -n 'contains_opts b back' -a "$path"
end

for path in $dirprev
  complete -fc $cmd -n "contains_opts p prevd" -a "$path"
end

for path in $dirnext
  complete -fc $cmd -n "contains_opts n nextd" -a "$path"
end
