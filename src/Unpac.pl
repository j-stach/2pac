

package Unpac;

use v5.14;
use Cwd;
use File::Basename;
use lib dirname($0);

use File;

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw(unpac);


sub unpac { # Restores serialized packages and files from vault. Requires sudo!
    my ($vault_path) = @_;

    my $registry = File::load_registry($vault_path);
    my @packages = split('\n', $registry);
    system("pacman -Syu", join(' ', @packages));
    File::close_file($registry);
    
    my @files = split('\n', system("ls $vault_path"));
    for my $file (@files) {
        unless $file =~ "registry.txt" || $file =~ "tracking.txt" {
            File::restore_filepath($file)
        }
    }
}



1;
