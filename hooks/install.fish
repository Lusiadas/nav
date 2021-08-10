command wget -qO $path/subfunctions/dependency.fish \
https://gitlab.com/argonautica/dependency/raw/master/dependency.fish
source $path/subfunctions/dependency.fish -n $package -p percol tree grep sed mlocate