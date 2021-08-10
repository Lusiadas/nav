# nav

> *A plugin for [Oh My Fish](https://www.github.com/oh-my-fish/oh-my-fish).*

[![GPL License](https://img.shields.io/badge/license-GPL-blue.svg?longCache=true&style=flat-square)](/LICENSE)
[![Fish Shell Version](https://img.shields.io/badge/fish-v3.0.1-blue.svg?style=flat-square)](https://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-blue.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)

<br/>

## Summary

### [1. Description](#description)

### [2. Example Usage](#example-usage)

### [3. Options](#options)

### [4. Installation](#installation)

### [5. Configuration](#configuration)

### [6. Thanks](#thanks)

## Description

**Navigational Assistance with Velocity**. In brief, it finds a folder whose name matches search patterns and makes it the current working directory. Ambiguities prompt the user to choose a directory from a list ordered on the basis of folders that have been used most often and most recently.

## Example usage
[![asciicast](https://asciinema.org/a/BVTfmYKMmB8baVXngV2dmeNwD.png)](https://asciinema.org/a/BVTfmYKMmB8baVXngV2dmeNwD)

## Options

### Navigation

`nav [pattern] ...`

If no argument is provided, list bookmarks. Otherwise, look for a directory in the navigation history that matches the patterns given and go there.

`nav -w/--where [pattern] ...`

Go to a directory in the navigation history.

`nav -t/--to [pattern] ...`

Go to a bookmarked directory.

`nav -f/--foward [pattern] ...`

Go to the closest child folder that matches passed patterns.

`nav -b/--back [pattern] ...`

Go to the closest parent folder that matches passed patterns.

`nav -p/--prev [pattern] ...`

Navigate to a previous directory in the navigation history.

`nav -n/--next [pattern] ...`

Navigate to a following dorectory in the navigation history.

#### Modifiers

`nav [-t/-w/-f/-b/-p/-n] -e/--echo`

Print destination instead.

`nav [-t/-w/-f/-b] -c/--commander [pattern] ...`

Open directory using mc, a.k.a. the Midnight Commander. A directory can be opened for each panel by dividing search patterns using ','.

### Bookmarking

`nav -s/--save [name] [destination] ...`

Bookmark directories. If only a name is provided, the current directory is bookmarked.

`nav -r/--remove [bookmark/all] ...`

Remove some, or all, saved bookmarks or bookmark folders.

`nav -m/--move [source] ... [destination]`

Move or rename bookmarks or bookmark folders.

`nav -a/--autoremove`

Remove bookmarks of folders that no longer exist. Bookmarks with destinations starting with "/media" will be ignored.

`nav -l/--list [folder] ...`

List the contents of the bookmarks folder or some inner folders.

`nav --backup [restore] [file]`

Create, or restore from, a backup file containing all bookmarks. If no file is specified, it'll create, or look for, a backup file in the current folder.

### Miscellaneous

`nav --abbr`

Add, or otherwise remove, abbreviations for interactive use:

- `w` for `nav --where`
- `t` for `nav --to`
- `f` for `nav --foward`
- `b` for `nav --back`
- `p` for `nav --prevd`
- `n` for `nav --nextd`
- `l` for `nav --list`

`nav --help`

Display these instructions

## Install

```fish
omf repositories add https://gitlab.com/argonautica/argonautica
omf install nav
```

### Dependencies

#### Required

> If any of the following dependencies isn't installed, upon installing nav you'll be prompted to install them.

```
curl contains_opts feedback grep percol mlocate sed tree
```

#### Optional

To use the `--commander` option, [mc](https://midnight-commander.org/) (a.k.a Midnight Commander) needs to be installed.

## Configuration

When `nav` loads along with the shell, it can set the latest directory in the navigation history as the current working directory. This behaviour helps to avoid bloating the navigation history with directories the user frequently opens as soon as the terminal is launched.

To activate this behaviour add the line `set -g _nav_resume true` to your fish config file. Like so:

```
echo 'set -g _nav_resume true' >> ~/.config/fish/config.fish
```

and to remove said behavior:

```
sed -i '/_nav_resume/d' ~/.config/fish/config.fish
```

## Thanks

This script was inspired by, and was based on, the work of theses nice fellows:

- [z](https://github.com/rupa/z), by rupa
- [bashmarks](https://github.com/huyng/bashmarks), by huyng
- [bookmark_dir](https://github.com/maku77/bookmark_dir), by maku77
- [bd](https://github.com/vigneshwaranr/bd), by vigneshwaranr

Also, it was written with the constant support of fish's [gitter channel](https://gitter.im/fish-shell/fish-shell).

**Thank you all for your contributions!**

---

Ⓐ Made in Anarchy. No wage slaves were economically coerced into the making of this work.
