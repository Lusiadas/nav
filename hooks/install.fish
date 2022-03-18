command wget -qO $path/subfunctions/dependency.fish \
https://git.disroot.org/lusiadas/dependency/raw/branch/master/dependency.fish
source $path/subfunctions/dependency.fish -n $package -p percol tree grep sed mlocate
