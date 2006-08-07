use strict;
use Test::More tests => 20;
use Module::Build;

my $build = Module::Build->current();


#1
BEGIN { use_ok('WebService::CIA::Source::Web'); }

my $source = WebService::CIA::Source::Web->new;

#2
ok( defined $source, 'new() - returns something' );

#3
ok( $source->isa('WebService::CIA::Source::Web'), 'new() - returns a WebService::CIA::Source::Web object' );

#4
ok( ref $source->ua eq 'LWP::UserAgent', 'ua() - returns LWP::UserAgent object' );

#5
ok( ref $source->parser eq 'WebService::CIA::Parser', 'parser() - returns WebService::CIA::Parser object' );

#6
ok( $source->cached eq '', 'cached() - returns empty string after new()' );

#7
ok( scalar keys %{$source->cache} == 0, 'cache() returns empty hashref after new()' );

SKIP: {

    skip "Skipping internet-based tests", 8 if $build->notes('internet') eq 'no';

#8
    ok( $source->get('uk') == 1, 'get() - returns 1' );

#9
    ok( $source->cached eq 'uk', 'cached() - cached country set correctly after get()' );

#10
    ok( scalar keys %{$source->cache} > 0 &&
        exists $source->cache->{'Background'} &&
        $source->cache->{'Background'}, 'cache() - cache contains values' );

#11
    ok( $source->value('uk','Background'), 'value() - valid args - returns a value' );

#12
    ok( ! defined $source->value('uk','Test'), 'value() (cached info) - invalid args - returns undef' );

#13
    ok( ! defined $source->value('testcountry', 'Test'), 'value() (non-cached info) - invalid args - returns undef' );

#14
    ok( scalar keys %{$source->all('uk')} > 0 &&
        exists $source->all('uk')->{'Background'} &&
        $source->all('uk')->{'Background'}, 'all() - valid args - returns hashref' );

#15
    ok( scalar keys %{$source->all('testcountry')} == 0, 'all() - invalid args - returns empty hashref' );

}

#16
$source->cached('testcountry');
ok( $source->cached eq 'testcountry', 'cached() - set data' );

#17
$source->cache({'Test' => 'Wombat'});
ok( exists $source->cache->{'Test'} &&
    $source->cache->{'Test'} eq 'Wombat', 'cache() - set data' );

#18
ok( $source->value('testcountry','Test') eq 'Wombat', 'value() (manually set data) - valid args - return test string' );

#19
ok( ! defined $source->value('testcountry','Blah'), 'value() (manually set data) - invalid args - return undef' );

#20
ok( scalar keys %{$source->all('testcountry')} == 1 &&
    exists $source->all('testcountry')->{'Test'} &&
    $source->all('testcountry')->{'Test'} eq 'Wombat', 'all() (manually set data) - return expected values' );
