

package Pacup;

use v5.14;
use Cwd;
use File::Basename;
use lib dirname($0);

use File;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(pacup);


sub pacup { # Serializes packages and tracked files/dirs to destination.

    # Register explicitly-installed pacman packages.
    my @packages = split('\n', system("sh pacman -Qe"));
    # TBD pacman option to find dotfile path?
    my $registry = File::create_registry();
    print $registry, join('\n', @packages), '\n';
    File::close_file($registry);

    # Save tracked files to vault.
    my $tracking = File::load_tracking();
    my @tracked = split('\n', $tracking);
    File::close_file($tracking);
    foreach (@tracked) {
        unless File::copy_file($_) { print "Tracked file $_ could not be saved; it may have been moved or deleted." }
    }
}


1;
