function nav -d "Navigational Assistance with Velocity"

    # Check for dependencies
    source $_nav_subfunctions/dependency.fish -n nav -p percol tree grep mlocate
    or return 1

    # Parse flags
    if argparse -n nav -x (string join -- ' -x ' h,w,t,f,b,n,p,s,r,m,l,a,x,d e,c,R {e,c,R},{h,s,r,m,l,a,x,d} | string split ' ') 'h/help' 'w/where' 't/to' 'f/forward' 'b/back' 'p/prevd' 'n/nextd' 's/save' 'r/remove' 'm/move' 'l/list' 'a/autoremove' 'x/abbr' 'd/backup' 'e/echo' 'c/commander' 'R/ranger' 'y/assume-yes' -- $argv 2>&1 | read err
        err $err
        reg "Use |nav -h| to see examples of valid syntaxes"
        return 1
  end
  set -l flags (set --name | string match -r -- '(?<=_flag_).$')

  # Check for bookmark availability
  if string match -qr -- '[trmla]' $flags
      if not find $_nav_bookmarks -type l 2>/dev/null | string length -q
          err "nav: No bookmarks were saved. Save a bookmark using |nav -s|:"
          source $_nav_subfunctions/instructions.fish "nav -s/--save"
          return 1
end
  end

  # Check for argument
  if not isatty
      while read -l line
          set --append argv $line
end
  end
  test (string match -ar -- '[wtfsrmk]' "k$flags" \
  | string join '') != k -a -z "$argv"
  or test (string match -ar -- '[axk]' "k$flags" \
  | string join '') != k -a -n "$argv"
  if test $status = 0
      source $_nav_subfunctions/instructions.fish "nav -"(string match -vr '[ecR]' $flags)"/--\S+"
      return 1
  end

  # Call requested option
  if string match -qr -- '[twbfnpe]' $flags
      source $_nav_subfunctions/navigate.fish -{$flags} $argv
  else if string match -qr -- '[srma]' $flags
      source $_nav_subfunctions/bookmark.fish -{$flags} $argv
  else if contains l $flags
      source $_nav_subfunctions/list.fish $argv
  else if contains d $flags
      source $_nav_subfunctions/backup.fish $_flag_y $argv
  else if contains x $flags
      source $_nav_subfunctions/abbr.fish $_flag_y
  else if contains h $flags
      source $_nav_subfunctions/instructions.fish
      test -z "$argv"
  else if test "$argv"
      source $_nav_subfunctions/navigate.fish -w $argv
  else
      source $_nav_subfunctions/list.fish
  end
end
