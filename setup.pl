
use strict;
use warnings;
use Cwd;

# Run this using 'sudo' or add the desired components manually -- see SETUP.md for more details

my $program_name = "2pac";
my $program_file = getcwd()."/src/2pac.pl";
my $program = "'perl $program_file'";

# TODO ------ uninstall
# undo everything created by setup
# remove alias, delete repo's
# if install points to /, instead print dirnames to be deleted manually

my $cache = "$ENV{HOME}/.cache/2pac/";
my $vault = $cache.'vault/';
unless (-d $vault) {
	mkdir $cache or die "Failed to create directory: Please add $cache manually.\n$!\n" ;
	mkdir $vault or die "Failed to create directory: Please add $vault manually.\n$!\n" ;
	print "Created vault directory: $vault\n";
}

my $shell_path = $ENV{'SHELL'};
if ($shell_path =~ m{/bin/([^/]+)$}) {
	my $shell = $1;
	if (my $config = find_shell_config($shell)) {
		if (modify_config($shell, $config)) {
			print "Setup successful. Restart your shell for changes to take effect.\n";
		} else {
			print shell_config_error();
		}
	}
} else {
	print "ERROR: Shell could not be identified.";
	print shell_config_error();
}

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
	if (exists $local_config_files{$shell}) {
		my $config = $local_config_files{$shell};
		if (-e $config) {
			print "Config file found at $config\n";
			return $config;
		} else {
			print "ERROR: Shell configuration file not found.\n";
		}
	} elsif (exists $global_config_files{$shell}) {
		my $config = $global_config_files{$shell};
		if (-e $config) {
			print "Config file found at $config\n";
			return $config;
		} else {
			print "ERROR: Shell configuration file not found.\n";
		}
	} else {
		print "ERROR: Shell configuration file not found.\n";
		print shell_config_error();
	}
}

sub modify_config {
	my ($shell, $config) = @_;
	my $alias = generate_alias($shell);
	if (check_config($config, $alias) == 0) {
		print "Alias not present, adding to $config.\n";
		add_alias($config, $alias);
	}
	if (check_config($config, $alias) == 0) {
		print "ERROR: Failed to add alias.\n";
		return 0;
	} else { 
		print "Alias is present in $config\n";
		return 1; 
	}
}

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

sub check_config {
	my ($config, $alias) = @_;
	my $alias_line = "alias $alias\n";
	if (open my $fh, '<', $config) {
		while (my $line = <$fh>) {
			return 1 if $line eq $alias_line;
		}
		close $fh;
		return 0;
	} else {
		print "ERROR: Failed to read $config\n";
		return 0;
	}	
}

sub add_alias {
	my ($config, $alias) = @_;
	my $alias_line = "alias $alias\n";
	open my $fh, '>>', $config or die "ERROR: Failed to modify $config\n$!";
	print $fh $alias_line;
	close $fh;
    #TODO Record alias location in ~/.config/2pac.toml file for later removal
}

sub shell_config_error {
	return "ERROR: Unable to create alias for $program_name. Please add the alias for $program to your shell's configuration file.\n";
}


