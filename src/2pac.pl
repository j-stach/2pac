
# 2pac main procedure 

use v5.14;
use File::Basename;
use lib dirname($0);

use Files;
use Msg;

# Load config file. TBD What for?
my $config = &Files::load_config;

# Flag and argument state.
my $d;
my $p;
my $path; # TODO To array

# Process command line arguments.
if (@ARGV) {
    my ($command, @args) = @ARGV;
    # Parse flags, and path argument.
    foreach (@args) {
        if ($_ eq '-p') { $p = 1 }
        if ($_ eq '-d') { $d = 1 }
        else { $path = $_ }
    }
    # Execute command or display help documentation.
    if ($command eq 'track') { track($path) }
    elsif ($command eq 'pacup') { 
        &pacup;
        if ($p) { &push_git; }
        if ($d) { system("cp", $ENV{HOME}.'/.cache/2pac/', $path) }
    }
    elsif ($command eq 'unpac') { unpac($path) }
    else { &Msg::help }
} else { &Msg::help }

# Commit and try to push to remote git repository, if one is set up.
sub push_git {
    system("cd",  $ENV{HOME}.'/.cache/2pac/');
    my $today = &Files::get_current_date;
    system("git add . && git commit -m 'Pacup $today'");
    # TODO check if remote exists, 
    # and if it doesn't, check config to see if one is set,
    # if there is, try to set upstream, then
    system("git pull origin master"); # TBD Revisit alternate branch names
    system("git push origin master"); # TBD Revisit alternate branch names
    # TODO else &Msg::unsuccessful_push
}


# Add the specified file or directory to 2pac/tracking.txt.
sub track { 
    my $filepath = dirname(my ($file) = @_);
    my $filename = $filepath.'/'.$file;
    if (-e $filename) {
        my $tracking = Files::load_tracking();
        print $tracking, "$filename\n";
        Files::close($tracking);
    } else { die "Error: Couldn't find $file in this path" }
}


# Record packages and save tracked files/dirs to 2pac/vault.
sub pacup { 
    my $packages = qx{pacman -Qe};
    # TBD pacman option to find dotfile/config path?
    if (open my $fh, '>', $cache.'registry.txt') { print $fh $packages; } 
    else { die "registry.txt could not be created. Check permissions?" } # TODO Msg

    # Copy the files at the filepaths stored in 2pac/tracking.txt.
    my $tracking = Files::load_tracking();
    my @tracked = split('\n', $tracking);
    Files::close($tracking);
    if ($#tracked > 0) {
        foreach (@tracked) {
            unless (Files::save($_)) { 
                print "Tracked file $_ could not be saved; it may have been moved or deleted." 
            } # TODO or &Msg::missing_file
        }
    }
}
# Create a new registry, overwriting any existing registry.txt.
sub create_registry { 
}



# Restores serialized packages and files from cache. Requires sudo!
sub unpac { 
    my $cache_path;
    # If no path is provided, use the default in ~/.cache
    unless (($cache_path) = @_) { $cache_path = $File::cache }

    # Load and re-sync packages. (Non-destructive.)
    my $registry = Files::load_registry($cache_path);
    my @packages = split('\n', $registry);
    system("pacman -Syu", join(' ', @packages));
    Files::close($registry);
    
    # Load and restore files and directories. (Will overwrite.)
    my @files = split('\n', system("ls", $cache_path.'/vault'));
    for my $file (@files) {
        unless ($file =~ "registry.txt" || $file =~ "tracking.txt") {
            Files::restore($file)
        }
    }
}


