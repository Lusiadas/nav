argparse y -- $argv

# Check if abbreviations preexist
set -l abbr w --where t --to f --forward b --back l --list p --prevd n --nextd
set -l found
for i in (seq 1 2 (count $abbr))
    set -l j (math $i+1)
    abbr | string match -qe -- "$abbr[$i] 'nav $abbr[$j]'"
    and set --append found $abbr[$i]
end

# Add abbreviations and aliases, or remove them if they preexist
if test "$found"
    if not set --query _flag_y
        wrn 'The following abbreviations will be deleted: |'(string join '|, |' $found)'|.'
        read -n 1 -P 'Continue? [y/n]: ' | string match -qi y
        or exit 1
  end
  for match in $found
      abbr -e $match
  end
  win 'Abbreviations removed'
else
    for i in (seq 1 2 (count $abbr))
        abbr -a $abbr[$i] nav $abbr[(math $i + 1)]
  end
  win 'Abbreviations added'
end
omf reload
