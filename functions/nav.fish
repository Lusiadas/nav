function nav -d "⚓ Navigation Assistance with Velocity"

    # Check if required dependencies are installed and, if not, offer to have them installed.
    source $_nav_subfunctions/dependency.fish -n nav -p percol tree grep mlocate
    or return 1

    # Parse flags.
    if argparse -n nav -x (string join -- ' -x ' h,w,t,f,b,n,p,s,r,m,l,a,x,d e,c,R {e,c,R},{h,s,r,m,l,a,x,d} | string split ' ') 'h/help' 'w/where' 't/to' 'f/forward' 'b/back' 'p/prevd' 'n/nextd' 's/save' 'r/remove' 'm/move' 'l/list' 'a/autoremove' 'x/abbr' 'd/backup' 'e/echo' 'c/commander' 'R/ranger' 'y/assume-yes' -- $argv 2>&1 | read err
        err $err
        reg "Use |nav -h| to see examples of valid syntaxes"
        return 1
    end
    set -l flags (set --name | string match -r -- '(?<=_flag_).$')

    # For flags that require bookmarks, check for their availability.
    if test (count (string match -r -- '[trmla]' $flags)) -ne 0\
    -a (count (find $_nav_bookmarks -type l 2>/dev/null)) -eq 0
        err "nav: No bookmarks were saved. Save a bookmark using |nav -s|:"
        source $_nav_subfunctions/instructions.fish "nav -s/--save"
        return 1
    end

    # Check if arguments were passed.
    if not isatty
        while read -l line
            set --append argv $line
        end
    end
    if test \( (count (string match -r -- '[wtfsrm]' "$flags")) -ne 0 -a -z "$argv" \)\
    -o \( (count (string match -qr -- '[ax]' "$flags")) -ne 0 -a -n "$argv" \)
        source $_nav_subfunctions/instructions.fish \
        "nav -"(string match -vr '[ecR]' $flags)"/--\S+"
        return 1
    end

    # Call requested option
    if string match -qr -- '[twbfnpe]' $flags
        source $_nav_subfunctions/navigate.fish -{$flags} "$argv"
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
