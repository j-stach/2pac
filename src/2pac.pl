
# 2pac main procedure 

use v5.14;
use Cwd;
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
    elsif ($command eq 'unpac') { if ($path) { unpac($path) } else { &unpac; } }
    else { &Msg::help }
    # TODO Clean & untrack
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
    my $filepath = Cwd::abs_path(dirname(my ($file) = @_));
    my $filename = $filepath.'/'.$file;
    if (-e $filename) {
        if (open my $fh, '>>', $cache.'tracking.txt') { 
            print $fh "$filename\n"; close $fh;
        } else { die "tracking.txt exists but could not be accessed.\n$!" }
    } else { die "Error: Couldn't find $file in this path.\n$!" }
}


# Record packages and save tracked files/dirs to 2pac/vault.
sub pacup { 
    my $packages = qx{pacman -Qe};
    if (open my $fh, '>', $cache.'registry.txt') { 
        print $fh $packages; close $fh;
    } else { die "registry.txt could not be created.\n$!" }

    # Copy the files at the filepaths stored in 2pac/tracking.txt.
    # TODO Clean up tracking for non-existant files
    if (open my $fh, '<', $cache.'tracking.txt') { 
        while (my $tracked = <$fh>) {
            chomp $tracked;
            Files::save($tracked);
        }
    } else { die "tracking.txt exists but could not be accessed.\n$!" }
}


# Restores serialized packages and files from cache. Requires sudo!
sub unpac { 
    my $cache_path;
    # If no path is provided, use the default in ~/.cache
    unless (($cache_path) = @_) { $cache_path = $Files::cache }

    # Load and re-sync packages. (Non-destructive.)
    my @packages;
    if (open my $fh, '<', $cache_path.'registry.txt') { 
        while (my $line = <$fh>) {
            my $pattern = qr{(.*) [0..9\.]+-[0..9]+\n};
            if ($line =~ $pattern) {
                push @packages, $1;
            }
        }
    } else { die "registry.txt could not be read.\n$!" }
    system("sudo", "pacman", "-Syu", @packages);
    
    # Load and restore files and directories. (Will overwrite.)
    my $vault_dir = $cache_path.'vault/';
    my @files = split('\n', qx{ls $vault_dir});
    foreach (@files) {
        Files::restore($vault_dir, $_)
    }
}


