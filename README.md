# 2pac 
This is a personal tool I use to back up my toy laptop running Arch.
It is a collection of simple scripts for backing up essential documents,
directories, and dotfiles to a single git repoitory. It also records all 
explicitly-installed pacman packages to allow for easy restoration. <br>

`2pac` is designed for minimalist Arch configurations that rely on 
official pacman packages, and does not directly accomodate applications 
installed any other way, as it is not a true system snapshot. <br>

For this tool, I consider that a feature rather than a bug, as it 
makes it easier to reset my system to a "clean" state, by ignoring
forgotten and unused files. <br>

## How it works:
`vault/` <br> 
2pac uses a vault directory to store its records and files, which is 
initialized for git when it is created. This directory can be saved to 
an external drive and/or pushed to a remote repository for safekeeping, 
either manually or by using `2pac pacup -d PATH` or `-p`, respectively. 
<br>

`Config.toml` <br>
In addition to the tracking and package registry files, `vault/` contains 
a configuration file that can be used to declaratively set behavior.
**(Actual options TBD...)**<br>

#### track
`2pac track PATH` <br>
Records the full filepath for the given file or directory in 
`vault/tracking.txt`. This file is later read to determine which files 
should be copied to `vault/`. <br>

#### pacup
`2pac pacup [-p] [-d PATH]` <br>
Queries pacman for explicitly-installed packages and records the list in 
`vault/registry.txt`, then for every file/directory found in 
`tracking.txt`, copies that file to `vault/` under a filename that 
represents its path. <br>
**TODO:** It does this by escaping all `/` in the filepath so filepaths,
and safely accounts for names that have `\/` already in the filename.
However, more complicated escapes than that aren't covered and should be
renamed before using `2pac track`. <br>

The `-p` flag will attempt to push the updated `vault/` to its remote 
repository if one has been configured in git or is specified in 
`Config.toml`. <br>

The `-d PATH` option will attempt to copy `vault/` to that location. <br>

#### unpac
`2pac unpac Path/To/vault/` <br>
Clone the vault back from git or find it on the drive where it was stored.
Pass the location to `unpac` to sync pacman packages and restore the
directory structures and files saved in `vault/`.

## How to setup:
This script requires `git` and `perl v5.14` or greater, and it assumes 
you are using `pacman` as your package manager. <br>

You can install `2pac` the easy way:
1. `git clone https://github.com/j-stach/2pac.git`
2. `perl 2pac/setup.pl`

Or the hard way:
1. `git clone https://github.com/j-stach/2pac.git`
2. TODO


# IWOMM Disclaimer
It works on my machine and that's about all I can guarantee.
Submit an issue if you find a bug. Script is free to use and modify. 
Fork me harder daddy~
