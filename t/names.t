use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);

local @ARGV = ();
do './asciiquarium';
die $@ if($@);

my $dir = tempdir(CLEANUP => 1);
sub session {
	my ($file, $text) = @_;
	open(my $fh, '>', "$dir/$file") or die $!;
	print $fh $text;
	close($fh);
}

is_deeply([ main::session_names("$dir/missing") ], [], 'no sessions dir: no names');
session('1.json', qq({"pid":$$,"name":"Journey"}));
session('2.json', '{"pid":99999999,"name":"Dead"}');
session('3.json', qq({"pid":$$}));
session('4.json', 'not json');
session('5.key', qq({"pid":$$,"name":"Key"}));
is_deeply([ main::session_names($dir) ], [ 'Journey' ], 'only named, live sessions');

is_deeply([ main::herdr_names(undef) ], [], 'no herdr: no names');
is_deeply([ main::herdr_names('not json') ], [], 'herdr error: no names');
is_deeply([ main::herdr_names('{"result":"x"}') ], [], 'odd herdr reply: no names');
is_deeply([ main::herdr_names(q({"result":{"panes":[
	{"agent":"claude","terminal_title_stripped":"OSS"},
	{"agent":"codex","terminal_title_stripped":"executive | Peak Health"},
	{"agent":"claude","terminal_title_stripped":"a | b"},
	{"terminal_title_stripped":"winter@thinkpad:~"},
	{"agent":"codex","terminal_title_stripped":" "}
]}})) ], [ 'OSS', 'executive', 'a | b' ], 'agent panes by title; codex without its project');

done_testing();
