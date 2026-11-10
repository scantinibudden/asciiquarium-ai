use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);

my $dir = tempdir(CLEANUP => 1);
local $ENV{'XDG_CONFIG_HOME'} = $dir;
local @ARGV = ();
do './asciiquarium';
die $@ if($@);

my $file = "$dir/asciiquarium-ai/config";
mkdir "$dir/asciiquarium-ai";

sub config_from {
	my ($text) = @_;
	open(my $fh, '>', $file) or die $!;
	print $fh $text;
	close($fh);
	return { main::read_config($file) };
}

my %defaults = (decoration => 'random', cooldown => 30);

is_deeply({ main::read_config("$dir/missing") }, \%defaults, 'missing file: defaults');
is_deeply(config_from(''), \%defaults, 'empty file: defaults');
is_deeply(config_from("decoration = skull\ncooldown = 45\n"),
	{ decoration => 'skull', cooldown => 45 }, 'both values read');
is_deeply(config_from("  Decoration=Anchor  # the good one\n"),
	{ decoration => 'anchor', cooldown => 30 }, 'case, spacing and comments tolerated');
is(config_from("decoration = castle\n")->{'decoration'}, 'castle', 'castle can be chosen');
is(config_from("decoration =\n")->{'decoration'}, 'random', 'empty decoration: random');
is(config_from("decoration = kraken\n")->{'decoration'}, 'random', 'unknown decoration: random');
is(config_from("cooldown = soon\n")->{'cooldown'}, 30, 'non-numeric cooldown: default');
is(config_from("cooldown = -5\n")->{'cooldown'}, 30, 'negative cooldown: default');
is(config_from("cooldown =\n")->{'cooldown'}, 30, 'empty cooldown: default');
is_deeply(config_from("\x00\xff garbage {{{\n=\n= 5\nfish = 3\n"), \%defaults, 'garbage: defaults');

unlink $file;
mkdir $file;
is_deeply({ main::read_config($file) }, \%defaults, 'a directory where the file should be: defaults');
rmdir $file;

SKIP: {
	skip 'root can read anything', 1 if($> == 0);
	config_from("cooldown = 45\n");
	chmod 0000, $file;
	is_deeply({ main::read_config($file) }, \%defaults, 'unreadable file: defaults');
	chmod 0644, $file;
}

done_testing();
