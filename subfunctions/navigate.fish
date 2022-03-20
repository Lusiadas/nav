argparse t w b f n p c R e y -- $argv

# Declare variables
set -l flag (set --name | string match -r -- '(?<=_flag_)[twfnpb]$')
set -l matches
set -l not_found

# Check if the file manager options were invoked
if test -n "$_flag_c" -o -n "$_flag_e"
    if set --query _flag_c
        if not type -qf mc
            if not set --query _flag_y
                wrn "The installation of |mc|, a.k.a. midnight commander, is necessary to use\
                the |--commander| option"
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
    else
        if not type -qf ranger
            if not set --query _flag_y
                wrn "The installation of |ranger| is necessary to use the |--ranger| option"
                read -n 1 -P "Install it? [y/n]:" | string match -qi y
                or exit 1
            end
            source $_nav_functions/dependency.fish -n nav ranger
            or exit 1
        end
    end
    set argv (string split -- , "$argv")
end

# "back" option
if string match -q b $flag
    if test "$argv"
        for arg in $argv
            string match -qr -- '/$' "$arg"
            and set --append matches (command realpath $PWD \
            | string match -r -- "(?i).*$arg")
            or set --append matches (command dirname (command realpath $PWD) \
            | string match -r -- "(?i).*""$arg""[^/]*")
            or set --append not_found "$arg"
        end
    else
        set matches (command dirname (command realpath $PWD))
    end

# "to", "where", "forward", "nextd", "prevd" options
else

    # If the "nextd" or "prevd" option were invoked
    if test "$flag" = n
        if test -z "$dirnext"
            dim "You're already at the latest folder in the navigation history."
            exit 0
        else if test -z "$argv"
            set argv "$dirnext[-1]"
        end
    else if test "$flag" = p
        if test -z "$dirprev"
            dim "You're already at the oldest folder in the navigation history."
            exit 0
        else if test -z "$argv"
            set argv "$dirprev[-1]"
        end
    end

    for arg in $argv

        # If there's an exact match
        set -l pool
        switch $flag
          case t
              test -L "$_nav_bookmarks/$arg"
          case w
              command cat $_nav_history | string match -q "$arg"
          case f
              test -d "$PWD/$arg"
          case n
              contains "$arg" "$dirnext"
          case p
              contains "$arg" "$dirprevd"
        end
        and set pool "$arg"

        # If not
        if test -z "$pool"
            set arg (string split ' ' $arg)
            string match -vqr '[np]' "$flag"
            and not set --query _flag_e
            and wrn -n "Searching..."

            if string match -q t $flag
                set pool (command find $_nav_bookmarks -type l 2>/dev/null \
                | string match -r -- "(?<=$_nav_bookmarks/).+")
            else if string match -q f $flag
                set pool (command find "$PWD" -type d -iname "*$arg[1]*")
            else if string match -q w $flag
                set pool (command locate -i (string match -r "^[^/ ]+" "$arg[1]"))
            else if string match -q n $flag
                set pool $dirnext
            else
                set pool $dirprev
            end

            # Filter pool for each passed pattern
            for pattern in $arg
                set pool (string match -ei "$pattern" $pool)
            end

            # Filter out hidden git folders, folders in the trash, or deleted folders
            set pool (string match -vr '(\.git(/|$)|/Trash/)' $pool \
            | string match -ei (string match -r "^\S+" "$arg"))
            for result in $pool
                test -d "$result"
                or set pool (string match -v "$result" $pool)
            end
        end
        set --query _flag_e
        or reg -on

        # If no matches where found for the current pattern, remember that.
        if test -z "$pool"
            set --append not_found "$arg"
            continue

        # If various matches were found
        else if test (count $pool) -gt 1
            set -l list

            # List in order of relevance
            if string match -qr '[wtf]' $flag
                for match in $pool
                    string match -q t $flag
                    and set -l relevance (command grep -n\
                    (command realpath "$_nav_bookmarks/$match") $_nav_history)
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
            | command percol --query "$arg" \
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
else if set --query _flag_R
    command ranger $matches
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
