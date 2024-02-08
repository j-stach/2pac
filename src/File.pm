
package File;

use v5.14;
use Cwd;
use File::Basename;
use lib dirname($0);

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw($vault_dir load_config load_tracking load_registry get_filename filename_from_path get_current_date);


our $dir = dirname($0);
our $root = dirname($dir);
our $vault_dir = $root.'/vault/';

sub load_config { # Get the read-handle for 2pac.toml, creating a new one from default if it doesn't exist.
    my $toml = $vault_dir.'2pac.toml';
    if (-e $toml) { if (open my $fh, '<', $toml) { return $fh } else { die "2pac.toml exists but could not be loaded. Check permissions?" }}
    else { if (open my $new, '>', $toml) { print $new &default_config; close $new; &load_config } else { die "Failed to create $toml...\n\ $!" }}
}

sub default_config { "# Behavior for 2pac can be configured here:\n" } # TBD Options for 2pac

sub load_tracking { # Get the append-handle for tracking.txt, creating a new empty file if it doesn't exist.
    my $tracking = $vault_dir.'tracking.txt';
    if (-e $tracking) { 
        if (open my $fh, '>>', $tracking) { return $fh } 
        else { die "tracking.txt exists but could not be loaded. Check permissions?" }
    } else { die "tracking.txt does not exist!" }
} 

sub append_tracking { # Get the append-handle for tracking.txt, creating a new empty file if it doesn't exist.
    my $tracking = $vault_dir.'tracking.txt';
    if (-e $tracking) { 
        if (open my $fh, '>>', $tracking) { return $fh } 
        else { die "tracking.txt exists but could not be loaded. Check permissions?" }
    } else { 
        if (open my $new, '>', $tracking) { close $new; &load_tracking } 
        else { die "Failed to create $tracking...\n\ $!" }
    }
} 

sub load_registry { # Get the read-handle for the package registry, registry.txt, if it exists.
    my $registry = $vault_dir.'registry.txt';
    if (-e $registry) { 
        if (open my $fh, '<', $registry) { return $fh } 
        else { die "registry.txt exists but could not be loaded. Check permissions?" }
    } else { die "$registry does not exist.\n\ $!" }
}

sub create_registry { # Create a new registry, overwriting any existing file.
    my $registry = $vault_dir.'registry.txt';
    if (open my $fh, '>', $registry) { return $fh } 
    else { die "registry.txt could not be created. Check permissions?" }
}

sub close_file { my ($fh) = @_; close $fh or die "Could not close file handle" } # Closes any open file

sub copy_file { # Attempts to copy file to the vault.
    my ($path) = @_;
    my $filename = filename_from_path($path);
    system("cp $path $vault_dir$filename")
}

sub filename_from_path { # Turns the filepath into a filename by escaping "/".
    return @_ =~ s/\//\\\//gr
    # TODO: return @_ =~ s/(^\\)\//\\\//gr
}

sub get_filename { # Gets the filename portion of a complete filepath.
	my ($filepath) = @_;
	my $filename_pattern = qr{/?(?<filename>[\.\p{L}\p{Nd}_]+)$};
	if ($filepath =~ $filename_pattern) { return $+{filename} }
    die "Filepath '$filepath' appears invalid";
}

sub get_current_date { # Gets the system timestamp for recordkeeping purposes.
	my ($sec, $min, $hour, $day, $mon, $year) = localtime();
	$year += 1900;
	my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
	my $month = $months[$mon];
	return "$day $month $year"
}

1;
