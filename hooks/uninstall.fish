# Remove abbreviations
set -l abbr w --where t --to f --foward b --back l --list p prevd n nextd
for i in (seq 1 2 (count $abbr))
    set -l j (math $i+1)
    if string match -qr [pn] $abbr[$i]
        abbr | string match -qe "$abbr[$i] $abbr[$j]"
    else
        abbr | string match -qe "$abbr[$i] '$package $abbr[$j]'"
  end
  and abbr -e $abbr[$i]
end
set --erase nav_bookmarks
set --erase nav_history

# Offer to uninstall dependencies
source $path/subfunctions/dependency.fish -rp percol grep sed mlocate mc tree
omf reload
