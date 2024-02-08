
package Help;

use v5.14;
use Cwd;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(help);

sub help { print("
2pac v0.1.0 (c) j-stach

2pac track PATH
Adds the file or directory specified by PATH to be tracked by 2pac.

2pac pacup [-p] [-d PATH]
Saves package list and tracked files to the vault.
If -p flag was passed, pushes to the remote git repo set up for vault/.
If -d was passed, copies vault/ to the location specified by PATH.

2pac unpac Path/To/vault
Syncs packages and restores filepaths for files stored in vault.

See https://github.com/j-stach/2pac/README.md for more information.
")}
