argparse t w b f n p c e y -- $argv

# Declare variables
set -l flag (set --name | string match -r -- '(?<=_flag_)[twfnpb]$')
set -l matches
set -l not_found

# Check if commander option was invoked
if set --query _flag_c
  if not type -qf mc
    if not set --query _flag_y
      wrn "The installation of |mc|, a.k.a. midnight commander, is necessary to use the |--commander| option"
      read -n 1 -P "Install it? [y/n]:" | string match -qi y
      or exit 1
    end
    source $_nav_functions/dependency.fish -n nav mc
    or exit 1
  end
  if test (string match -ar -- , $argv | wc -w) -gt 1
    err "$cmd: More than 2 sequences of patterns were passed"
    source $_nav_functions/instructions.fish "nav -c/--commander"
    exit 1
  end
  set argv (string split -- , "$argv")
end

# "back" option
if string match -q b $flag
  if test "$argv"
    for i in (command seq (count $argv))
      string match -qr -- '/$' $argv[$i]
      and set --append matches (command realpath $PWD \
      | string match -r -- "(?i).*$argv[$i]")
      or set --append matches (command dirname (command realpath $PWD) \
      | string match -r -- "(?i).*$argv[$i][^/]*")
      test "$matches[$i]"
      or set --append not_found $argv[$i]
    end
  else
    set matches (command dirname (command realpath $PWD))
  end

# "to", "where", "foward", "nextd", "prevd" options
else

  # Test if an argument was passed
  test "$flag" = n -a -z "$argv"
  and set argv "$dirnext[-1]"
  test "$flag" = p -a -z "$argv"
  and set argv "$dirprev[-1]"
  for i in (command seq (count $argv))

    # If there's an exact match
    set -l pool
    switch $flag
      case t
        test -L "$_nav_bookmarks/$argv[$i]"
      case w
        command cat $_nav_history | string match -q "$argv[$i]"
      case f
        test -d "$PWD/$argv[$i]"
      case n
        contains "$argv[$i]" "$dirnext"
      case p
        contains "$argv[$i]" "$dirprevd"
    end
    and set pool "$argv[$i]"


    # If not
    if test -z "$pool"
      set --query _flag_e
      or string match -vqr '[np]' "$flag"
      or wrn -n "Searching..."

      # To option: search for bookmarks
      if string match -q $flag t
        set pool (command find $_nav_bookmarks -type l 2>/dev/null \
        | string match -r -- "(?<=$_nav_bookmarks/).+")
        for pattern in (string split -- ' ' $argv[$i])
          set pool (string match -ei "$pattern" $pool)
        end

      # "foward", "nextd", "prevd" and "where" option: search for paths
      else
        if string match -q f $flag
          if test (command find $PWD -type d -maxdepth 1 2>/dev/null | wc -l) -eq 1
            err -o "nav: No folders were found within this directory"
            exit 1
          end
          set pool (command locate $PWD)
        else if string match -q w $flag
          set pool (command locate -i (string match -r "^[^/ ]+" "$argv[$i]"))
        else if string match -q n $flag
          set pool $dirnext
        else
          set pool $dirprev
        end

        # Filter out hidden git folders, folders in the trash, or deleted folders
        set pool (string match -vr '(\.git(/|$)|/Trash/)' $pool \
        | string match -ei (string match -r "^\S+" "$argv[$i]"))
        for filter in (string split " " "$argv[$i]")
          set pool (string match -aei "$filter" $pool)
        end
        for i in (command seq (count $pool) | command tac)
          test -d "$pool[$i]"
          or set --erase pool[$i]
        end
      end
    end
    set --query _flag_e
    or reg -on

    # If no matches where found for the current pattern, remember that.
    if test -z "$pool"
      set --append not_found $argv[$i]
      continue

    # If various matches were found
    else if test (count $pool) -gt 1
      set -l list

      # List in order of relevance
      if string match -qr '[wt]' $flag
        for match in $pool
          string match -q t $flag
          and set -l relevance (command grep -n (command realpath "$_nav_bookmarks/$match") $_nav_history)
          or set -l relevance (command grep -n $match $_nav_history)
          string match -ar "^[0-9]+" $relevance \
          | string join + \
          | command bc \
          | read relevance
          or set relevance 0
          set --append list "$relevance $match"
        end
        set list (command printf "%s\n" $list \
        | command sort -nr \
        | string replace -ar "^\d+\s+" "")

      # List chronologically
      else
        string match -q n $flag
        and set list (printf "%s\n" $dirnext | tac)
        or set list (printf "%s\n" $dirprev | tac)
      end

      # And prompt the user to choose between the remaining matches
      command printf "%s\n" $list \
      | command percol --query $argv[$i] \
      | read pool
      or exit 1
    end

    # Test if match does exist
    if string match -q t $flag
      if test -d "$_nav_bookmarks/$pool"
        set --append matches "$_nav_bookmarks/$pool"
        continue
      else if not set --query _flag_y
        wrn "The destination for bookmark |$pool| is unavailable"
        read -n 1 -P "Delete bookmark? [y/n]: " | string match -qi y
        or continue
      end
      command sed -i "\|^"(command realpath "$_nav_bookmarks/$pool")"\$|d" "$_nav_history"
      command rm "$_nav_bookmarks/$matches[$i]"
    else
      if test -d "$pool"
        set --append matches "$pool"
        continue
      end
      err "Directory |$pool| no longer exists"
      command sed -i "\|^$pool\$|d" $_nav_history
    end
  end
end


# If patterns weren't matched
if test "$not_found" -a -z "$flag_n" -a -z "$flag_p"
  if test -z "$_flag_t" -o (count $argv) -gt 1
    err "nav: $not_found: No matches were found"
    exit 1
  end
  wrn "nav: $not_found: No bookmarks found for pattern"
  reg "Searching for pattern in navigation history..."
  nav --where $_flag_c $_flag_e $argv
end

# Navigate
if string match -qr '[np]' $flag
  test "$matches"
  or exit 1
end
if set --query _flag_c
  command mc $matches
else if set --query _flag_e
  echo (realpath $matches)
else
  if string match -q $PWD $matches
    dim "You're already there."
  else if string match -qvr '[np]' $flag
    cd $matches 2>/dev/null
  else if string match -q n $flag
    nextd (math (count $dirnext) - (contains -i $matches $dirnext) + 1)
  else
    prevd (math (count $dirprev) - (contains -i $matches $dirprev) + 1)
  end
end
