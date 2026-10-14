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

# name_fish against a stand-in animation: entities are hashes, methods are no-ops
{
	package Stub;
	our $AUTOLOAD;
	sub new { my ($class, %p) = @_; return bless({ %p }, $class) }
	sub new_entity { my ($self, %p) = @_; my $e = Stub->new(%p); push(@{$self->{'made'}}, $e); return $e }
	sub entity { my ($self, $name) = @_; return (grep { ($_->{'name'} // '') eq $name } @{$self->{'made'}})[0] }
	sub AUTOLOAD { return 0 }
	sub DESTROY {}
}
my @agents;
{
	no warnings 'redefine';
	*main::agent_names = sub { @agents };
	*main::add_fish = sub { Stub->new };
}
sub tags { map { $_->{'name'} =~ s/^name_tag://r } grep { $_->{'name'} } @{$_[0]{'made'}} }
sub gap { my $made = $_[0]{'made'}; my ($tick) = grep { $_->{'death_cb'} } reverse(@$made); $tick->{'die_time'} - time() }

my $anim = Stub->new;
@agents = ('A', 'B', 'B', 'C', 'D');
main::name_fish(undef, $anim) for(1 .. 6);
is_deeply([ sort(tags($anim)) ], [ 'A', 'B', 'C', 'D' ], 'each agent named once, then no more fish');
ok(abs(gap($anim) - 4) < 1, 'four agents: one every 4s');

$anim = Stub->new;
@agents = ('A');
main::name_fish(undef, $anim);
ok(abs(gap($anim) - 16) < 1, 'one agent: one every 16s');

$anim = Stub->new;
@agents = map { "agent $_" } 1 .. 40;
main::name_fish(undef, $anim);
ok(abs(gap($anim) - 1) < 1, 'many agents: no faster than one a second');

$anim = Stub->new;
@agents = ('x' x 24 . '1', 'x' x 24 . '2');
main::name_fish(undef, $anim) for(1 .. 2);
is_deeply([ tags($anim) ], [ 'x' x 24 ], 'names alike once cut are one name');

done_testing();
