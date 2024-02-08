
# 2pac main procedure 

use v5.14;
use File::Basename;
use lib dirname($0);

use File;


my $config = &File::load_config;

my $d;
my $p;
my $path;

foreach (@args) {
    if ($_ eq '-p') { $p = 1 }
    if ($_ eq '-d') { $d = 1 }
    else { $path = $_ }
}

if (@ARGV) {
    ($command, @args) = @ARGV;
    if ($command eq 'track') { track($path) }
    elsif ($command eq 'pacup') { 
        &pacup;
        if ($p) { &push_remote }
        if ($d) { system("cp", $ENV{HOME}.'/.cache/2pac/', $path) }
    }
    elsif ($command eq 'unpac') { unpac($path) }
    else { &Help::help }
}

sub push_remote {
    system("cd",  $ENV{HOME}.'/.cache/2pac/');
    system("git pull origin master"); # TBD Revisit alternate branch names
    my $today = &File::get_current_date;
    system("git add . && git commit -m 'Pacup $today'");
    system("git push origin master"); # TBD Revisit alternate branch names
}

sub track { # Adds the specified file or directory to tracking.txt
    my $filepath = dirname(my ($file) = @_);
    if (-e $filepath.'/'.$file) {
        my $tracking = load_tracking();
        print $tracking, "$filepath/$file\n";
        File::close_file($tracking);
    } else { die "Error: Couldn't find $file in this path" }
}


sub pacup { # Serializes packages and tracked files/dirs to destination.
    my @packages = split('\n', system("pacman -Qe"));
    # TBD pacman option to find dotfile path?
    my $registry = File::create_registry();
    print $registry, join('\n', @packages), '\n';
    File::close_file($registry);

    my $tracking = File::load_tracking();
    my @tracked = split('\n', $tracking);
    File::close_file($tracking);
    foreach (@tracked) {
        unless (File::copy_file($_)) { print "Tracked file $_ could not be saved; it may have been moved or deleted." }
    }
}


sub unpac { # Restores serialized packages and files from cache. Requires sudo!
    my ($cache_path) = @_;

    my $registry = File::load_registry($cache_path);
    my @packages = split('\n', $registry);
    system("pacman -Syu", join(' ', @packages));
    File::close_file($registry);
    
    my @files = split('\n', system("ls", $cache_path.'/vault'));
    for my $file (@files) {
        unless $file =~ "registry.txt" || $file =~ "tracking.txt" {
            File::restore_filepath($file)
        }
    }
}


