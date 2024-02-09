
package Files;

use v5.14;
use Cwd;
use File::Basename;
use lib dirname($0);

use Exporter 5.57 'import';
our $VERSION = '0.10';
our @EXPORT = qw($cache $vault $config load_config load_tracking load_registry close get_current_date save restore);


# Default file locations:
our $config = $ENV{HOME}.'/.config/2pac.toml';
our $cache = $ENV{HOME}.'/.cache/2pac/';
our $vault = $cache.'vault/';


# Produces the configuration template for 2pac.toml. 
my $default_config = "
# Behavior for 2pac can be configured here:
[2pac]
# Remote git repository. Use branch name 'cache' to set up.
# remote = \"\"
# remote_name = \"\"
# Default flags to pass. Path args need to be supplied independently.
# flags = [\"d\", \"p\"]
# Default backup path. Will be applied for all -d path args.
# backup = \"\"
"; 

# Get the read-handle for 2pac.toml, creating a new one from default if it doesn't exist.
sub load_config {
    if (-e $config) { 
        if (open my $fh, '<', $config) { return $fh } 
        else { die "2pac.toml exists but could not be loaded. Check permissions?" }
    }
    else { 
        if (open my $new, '>', $config) { 
            print $new $default_config; 
            close $new; 
            &load_config 
        } 
        else { die "Failed to create $config...\n$!" }
    }
}


# Get the append-handle for tracking.txt, creating a new empty file if it doesn't exist.
sub load_tracking { 
    my $tracking = $cache.'tracking.txt';
    if (-e $tracking) { 
        if (open my $fh, '>>', $tracking) { return $fh } 
        else { die "tracking.txt exists but could not be accessed. Try using 'sudo'." } # TODO Msg
    } else { 
        if (open my $new, '>', $tracking) { close $new; &load_tracking } 
        else { die "Failed to create $tracking...\n\ $!" }
    }
} 


# Get the read-handle for the package registry, registry.txt, if it exists.
sub load_registry { 
    local ($cache) = @_;
    my $registry = $cache.'registry.txt';
    if (-e $registry) { 
        if (open my $fh, '<', $registry) { return $fh } 
        else { die "registry.txt exists but could not be loaded. Check permissions?" } # TODO Msg
    } else { die "$registry does not exist.\n\ $!" }
}


# Drop an open file handle.
sub close { my ($fh) = @_; close $fh or die "Could not close file handle." }


# Turns the filepath into a filename by escaping "/".
sub filename_from_path { my ($name) = @_ =~ s/\//\\\//gr; return $name }
# Turns the filename into a filepath by removing all escapes before "/".
sub filename_to_path { my ($path) = @_ =~ s/\\\//\//gr; return $path }

# Copies file to the vault.
sub save { 
    my ($path) = @_;
    my $filename = filename_from_path($path);
    system("cp $path $vault$filename"); # TODO Test on directories too?
}

# Restores file to original path, recreating directories if necessary.
sub restore {
    my ($archive, $serde_file) = @_;
    my $filepath = filename_to_path($serde_file);
    my @path = split('/', $filepath);
    # Walk down the path and recreate missing directories.
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
    # Retrieve the filename and copy file to that name.
    my $filename = get_filename($filepath);
    system("cp $archive$serde_file $filename") # TODO force overwrite
}

# Gets the filename portion of a complete filepath string.
sub get_filename { 
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
