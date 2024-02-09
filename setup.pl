
use v5.14;
use Cwd;
use File::Basename;

# Run this using 'sudo' or add the desired components manually -- see SETUP.md for more details

my $program_name = "2pac";
my $program_file = Cwd::abs_path(dirname(__FILE__))."/src/2pac.pl"; #? Lol
my $program = "'perl $program_file'";

# TODO ------ uninstall
# undo everything created by setup
# remove alias, delete repo's
# if install points to /, instead print dirnames to be deleted manually

# Set up 2pac config file.
my $config = "$ENV{HOME}/.config/2pac.toml";
# TODO Create config file

# Set up the cache and vault directories.
my $cache = "$ENV{HOME}/.cache/2pac/";
my $vault = $cache.'vault/';
unless (-d $vault) {
	mkdir $cache 
        or die "Failed to create directory: Please add $cache manually.\n$!\n";
	mkdir $vault 
        or die "Failed to create directory: Please add $vault manually.\n$!\n";
	print "Created vault directory: $vault\n";
}
# TODO git init

# Set up the alias "2pac" in the user's shell.
my $shell_path = $ENV{'SHELL'};
if ($shell_path =~ m{/bin/([^/]+)$}) {
	my $shell = $1;
	if (my $shell_config = find_shell_config($shell)) {
		if (modify_config($shell, $shell_config)) {
            &shell_config_success;
		} else {
			&shell_config_error;
		}
	}
} else {
	print "ERROR: Shell could not be identified.";
	&shell_config_error;
}


# Find the shell configuration file.
sub find_shell_config {
	my ($shell) = @_;
	my %local_config_files = (
		'bash' => "$ENV{HOME}/.bashrc",
		'zsh'  => "$ENV{HOME}/.zshrc",
		'fish' => "$ENV{HOME}/.config/fish/config.fish",
		'tcsh' => "$ENV{HOME}/.tcshrc",
		'ksh'  => "$ENV{HOME}/.kshrc",
		'csh'  => "$ENV{HOME}/.cshrc",
	);
	my %global_config_files = (
		'bash' => '/etc/bash.bashrc',
		'zsh'  => '/etc/zsh/zshrc',
		'fish' => '/etc/fish/config.fish',
		'tcsh' => '/etc/tcsh.cshrc',
		'csh'  => '/etc/csh.cshrc',
	);

    # Attempt to find the user's shell first,
	if (exists $local_config_files{$shell}) {
		my $shell_config = $local_config_files{$shell};
		if (-e $shell_config) {
			print "Config file found at $shell_config\n";
			return $shell_config;
        # Then try to find global config if there isn't one for the user.
	    } elsif (exists $global_config_files{$shell}) {
	    	my $shell_config = $global_config_files{$shell};
	    	if (-e $shell_config) {
	    		print "Config file found at $shell_config\n";
	    		return $shell_config;
            # Otherwise, it must be added manually.
	    	} else { print "ERROR: Shell configuration file not found.\n"; }
        } else { print "ERROR: Shell configuration file not found.\n"; }
	} else { print "ERROR: Shell configuration not supported.\n"; }
	&shell_config_error;
}

# Add the alias for 2pac to the shell config.
sub modify_config {
	my ($shell, $shell_config) = @_;
	my $alias = generate_alias($shell);
	if (check_shell_config($shell_config, $alias) == 0) {
		print "Alias not present, adding to $shell_config.\n";
		add_alias($shell_config, $alias);
	}
	if (check_shell_config($shell_config, $alias) == 0) {
		print "ERROR: Failed to add alias.\n";
		return 0;
	} else { 
		print "Alias is present in $shell_config\n";
		return 1; 
	}
}

# Generate the alias pattern based on shell syntax.
sub generate_alias {
	my ($shell) = @_;
	my %aliases = (
		'bash' => $program_name.'='.$program,
		'zsh' => $program_name.'='.$program,
		'fish' => $program_name.' '.$program,
		'tcsh' => $program_name.' '.$program,
		'ksh' => $program_name.'='.$program,
		'csh' => $program_name.' '.$program,
	);
	if (exists $aliases{$shell}) {
		my $alias = $aliases{$shell};
		return $alias;
	}
}

# Check if the alias is already present in the shell config.
sub check_shell_config {
	my ($shell_config, $alias) = @_;
	my $alias_line = "alias $alias\n";
	if (open my $fh, '<', $shell_config) {
		while (my $line = <$fh>) {
			return 1 if $line eq $alias_line;
		}
		close $fh;
		return 0;
	} else {
		print "ERROR: Failed to read $shell_config\n";
		return 0;
	}	
}

# Inserts alias into shell config. 
# TODO Account for different config structures; match for placement; fish especially double check
sub add_alias {
	my ($shell_config, $alias) = @_;
	my $alias_line = "alias $alias\n";
	open my $fh, '>>', $shell_config or die "ERROR: Failed to modify $shell_config\n$!";
	print $fh $alias_line;
	close $fh;
    #TODO Record alias location in ~/.config/2pac.toml file for later removal w/ --uninstall
}

sub shell_config_error {
	die "ERROR: Unable to create alias for $program_name. Please add the alias for $program to your shell's configuration file.\n";
}
sub shell_config_success {
    print "Setup successful. Restart your shell for changes to take effect.\n";
}

