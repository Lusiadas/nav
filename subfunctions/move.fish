argparse y -- $argv

# Check destination validity
if string match -qr -- '^(all|history)$' $argv[-1]
  err "nav: $argv[-1]: Invalid bookmark or folder name"
  exit 1
end
if string match -qr -- '(^|/)\.' $argv[-1]
  err "nav: $argv[-1]: Can not move bookmarks or folders by naming them as being hidden"
  exit 1
end
if string match -qr -- '\s' $argv[-1]
  err "nav: $argv[-1]: Can not save bookmarks with names containing whitespaces"
  exit 1
end
if contains $argv[-1] $argv[1..-2]
  err "nav: $argv[-1]: Can not move |\$argv[-1]| into itself"
  exit 1
end

# Check if bookmarks or folders to be moved do exist
set -l not_found
for arg in $argv[1..-2]
  test -e "$_nav_bookmarks/$arg"
  or set --append not_found $arg
end
if test -n "$not_found"
  set not_found (string join '|, |' $not_found)
  err "nav: $not_found: No bookmarks nor folders where found for this pattern"
  reg "Use |$cmd -l| to see available bookmarks"
  exit 1
end

# Check if the destination contains a preexisting bookmark
if test -L $_nav_bookmarks/$argv[-1]
  if not set --query _flag_y
    wrn "A bookmark |\$_nav_bookmarks/$argv[-1]| already exists."
    read -n 1 -P "Overwrite it? [y/n]: " | string match -qi y
    or exit 1
  end
  command rm "$_nav_bookmarks/$argv[-1]"
end

# Move bookmarks and folders
command mkdir -p (string match -r ".+/" $_nav_bookmarks/$argv[-1])
command mv "$_nav_bookmarks/"{(string join , $argv)}
win "Moved |"(string join '|, |' $argv[1..-2])"|, to |$argv[-1]|."
