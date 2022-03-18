argparse y -- $argv

# Substitute relative paths for absolute paths
for i in (seq 1 2 (count $argv))
    string length -q $argv[(math $i + 1)]
    and set argv[(math $i + 1)] (command realpath $argv[(math $i + 1)])
end

# Substitute no path for the current path
math (count $argv) / 2 | string match -qe .
and set --append argv (command realpath $PWD)

for i in (command seq 1 2 (count $argv) | command sort -r)
    set -l j (math $i + 1)
    set -l failed

    # Check if the bookmark name is valid
    if string match -qr '^(all|history)$' $argv[$i]
        err "nav: $argv[$i]: Invalid bookmark name"
        set failed true
    end
    if string match -qr '(^|/)\.' $argv[$i]
        err "nav: $argv[$i]: Can't save bookmarks by naming them as hidden files or folders"
        set failed true
    end
    if string match -qr '\s' $argv[$i]
        err "nav: $argv[$i]: Can't save bookmarks with names containing whitespaces"
        set failed true
    end
    if string match -a $argv[$i] $argv[(command seq 1 2 (count $argv))] \
    | command uniq -d \
    | string length -q
        err "nav: $argv[$i]: Can't save multiple bookmarks with the name"
        set failed true
    end

    # Check if bookmark path is valid
    if string match -a (command realpath $argv[$j]) $argv[(command seq 2 2 (count $argv))] \
    | command uniq -d \
    | string length -q
        err "nav: $argv[$j]: Can't save multiple bookmarks for the same path"
        set failed true
    end
    test (string sub -l 7 $argv[$j]) = '/media/' -o -d "$argv[$j]"
    or string match -e "/mtp:" "$argv[$j]"
    if test $status = 1
        err "nav: $argv[$j]: Directory not found"
        set failed true
    end
    if test "$failed"
        set -e argv[$i $j]
        continue
    end

    # Check for a naming conflict
    if command find $_nav_bookmarks 2>/dev/null \
    | string match -r -- "(?<=$_nav_bookmarks/)$argv[$i](?=/|\$)" \
    | read same_name
        test -L "$_nav_bookmarks/$same_name"
        and wrn "A bookmark named |$argv[$i]| already exists."
        or wrn "A folder named |$argv[$i]| already exists."
        if not set --query _flag_y
            if read -n 1 -P "Overwrite it? [y/n]: " | string match -qvi y
                dim "Skipped adding bookmark |$argv[$i]|."
                continue
            end
        end
        rm -r "$_nav_bookmarks/$same_name"
    end

    # Check for matching destinations
    set -l bookmarks (find $_nav_bookmarks -type l 2>/dev/null)
    if contains -i $argv[$j] (readlink $bookmarks 2>/dev/null) 2>/dev/null \
    | read k
        if test -z "$k"
            wrn "Directory |$path| already assigned to bookmark |"(command basename $bookmarks[$k])\
            "|."
            if read -P "Replace it? [y/n]: " | string match -qvi y
                dim "Skipped adding bookmark |$argv[$i]|."
                continue
            end
        end
        command rm "$bookmarks[$i]"
    end

# Create folders as needed, and save the bookmark
    command mkdir -p (string match -r ".+/" $_nav_bookmarks/$argv[$i])
    command ln -sf "$argv[$j]" "$_nav_bookmarks/$argv[$i]"
    set --append saved $argv[$i]
end

# Reply with result
test "$saved"
or exit 1
test (count $saved) -eq 1
and win "Bookmark |$saved| added."
or win "Bookmarks |"(string join "|, |" $saved)"| added."
