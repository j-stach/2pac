
package File;

use v5.14;
use Cwd;
use File::Basename;
use lib dirname($0);

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw($vault_dir load_config load_tracking load_registry get_filename filename_from_path get_current_date \
copy_file restore_file);


our $config = '~/.config/2pac.toml';
our $cache = '~/.cache/2pac/';
our $vault = $cache.'vault/';

sub load_config { # Get the read-handle for 2pac.toml, creating a new one from default if it doesn't exist.
    if (-e $config) { if (open my $fh, '<', $config) { return $fh } else { die "2pac.toml exists but could not be loaded. Check permissions?" }}
    else { if (open my $new, '>', $config) { print $new &default_config; close $new; &load_config } else { die "Failed to create $config...\n$!" }}
}

sub default_config { "# Behavior for 2pac can be configured here:\n" } # TBD Options for 2pac

sub load_tracking { # Get the append-handle for tracking.txt, creating a new empty file if it doesn't exist.
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
    local ($vault_dir) = @_;
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
    system("cp $path $vault_dir$filename");
}

sub filename_from_path { # Turns the filepath into a filename by escaping "/".
    my ($file_name) = @_ =~ s/\//\\\//gr;
    # TODO: return @_ =~ s/(^\\)\//\\\//gr
    return $file_name;
}

sub filename_to_path {
    my ($file_name) = @_ =~ s/\\\//\//gr;
    return $file_name;
}

sub restore_filepath {
    my ($vault_path, $serde_file) = @_;
    my $filepath = filename_to_path($serde_file);
    my @path = split('/', $filepath);
    system("cd");
    for my $i (0 .. $#path-1) {
        my $dir = $path[$i];
        if (-e $dir) { system("cd $dir"); continue }
        else {
            system("mkdir $dir");
            system("cd $dir"); 
            continue 
        }
    }
    my $filename = get_filename($filepath);
    system("cp $vault_path$serde_file $filename")
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
