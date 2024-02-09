
package Msg;

use v5.14;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(help);

sub help { print("
2pac v0.1.0 (c) j-stach
See https://github.com/j-stach/2pac/README.md for more information.

\$ 2pac track [PATH]
    Adds a file or directory specified by PATH to be tracked by 2pac.
    TODO: Simultaneous additions are currently unsupported; 
    multiple arguments may be provided but only the last will be stored.

\$ 2pac pacup <-p> <-d PATH>
    Saves package list and tracked files to ~/.cache/2pac.
    If -p flag was passed, pushes to the remote git repo set up for the cache.
    If -d was passed, copies the cache to a location specified by PATH.

\$ sudo 2pac unpac <Path/To/Cache>
    Syncs packages in registry and restores paths for files in vault.
    If Path/To/Cache is provided, 2pac will attempt to unpac that directory,
    otherwise ~/.cache/2pac will be used.

")}






1;
