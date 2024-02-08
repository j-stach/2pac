
# 2pac main procedure 

use v5.14;
use File::Basename;
use lib dirname($0);

use File;
use Pacup;


# ------ 2pac
# ensure setup & config is correct
# set global vars based on config
my $config = &File::load_config;

# process cli arguments: 2pac ...
# pacup <options>
# unpac <options> <source dir>
# track <list of paths>
#
# options like -p push to repo, -w write to disk

# ------ pacup
# if -d, parse all files for the appearance of filenames or paths, then attempt to locate and save any found
# warn to double-check config file dependencies are all accounted for, symlinks or aliases may not have been found, for ex. 
# if -p, and if git is known from gitinfo, push changes to repo
# if -w, and if disk was specifed, copy directory to disk
# end message

# ------ unpac
# if -p, pull vault from repository
# if -d, copy vault from disk location
# if blank, use the vault present in the script's root dir
# pacman -Syu for all packages in registry
# for all files in tracked files, get the associated file from vault
# search for that file at the registered location and replace the default
# if not present, regenerate any missing path to the registered point, then save file
# end message

# ------ track
# get the current directory & search for existence of path arg
# if it's a file, get the full path as string, and write to registry 

# ------ uninstall
# undo everything created by setup
# remove alias, delete repo's
# if install points to /, instead print dirnames to be deleted manually


# ------ 2pac-lives
# web-hosted script that calls pacstrap with perl5,
# then installs 2pac and runs unpac on the specified repo or disk

