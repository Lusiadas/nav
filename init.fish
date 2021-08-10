set -g _nav_bookmarks "$path/bookmarks"
set -g _nav_history "$path/history"
set -g _nav_subfunctions "$path/subfunctions"
test -s $_nav_history -a "$_nav_resume" = true
and cd (tail -1 $_nav_history)

function _update_history -v PWD -d "Manage navigation history"
  set -l cwd (command realpath $PWD)
  command realpath ~ | string match -q $cwd
  and return 0
  echo $cwd >> $_nav_history
  test (command wc -l $_nav_history | string match -r '\d+') -le 100
  and return 0
  command mv $_nav_history "$PREFIX"/tmp
  command tail -100 "$PREFIX"/tmp/history > $_nav_history
  command rm "$PREFIX"/tmp/history
end
