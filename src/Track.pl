
package Track;

use v5.14;
use Cwd;
use File::Basename;
use lib dirname($0);

use File;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(track);


sub track { # Adds the specified file or directory to tracking.txt
    my $filepath = dirname(my ($file) = @_);
    if (-e $filepath.'/'.$file) {
        my $tracking = append_tracking();
        print $tracking, "$filepath/$file\n";
        File::close_file($tracking);
    } else { die "Error: Couldn't find $file in this path" }
}

1;
