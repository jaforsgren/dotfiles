#!/usr/bin/env perl
# Filter between `overmind echo` and the combined log file: prefixes every line with a local
# ISO-8601 timestamp (lnav needs one to show the file as a log rather than plain text) and strips
# ANSI escape sequences so the lnav format regex matches the raw text.
use strict;
use warnings;
use POSIX qw(strftime);
use Time::HiRes qw(gettimeofday);

$| = 1;

while (my $line = <STDIN>) {
    # CSI sequences (colors, cursor moves), OSC sequences (titles) and two-byte escapes (e.g. ESC =).
    $line =~ s/\e(?:\[[0-9;?]*[ -\/]*[@-~]|\][^\a\e]*(?:\a|\e\\)|[=>@-Z\\-_])//g;
    $line =~ s/\r//g;
    my ($seconds, $microseconds) = gettimeofday();
    printf "%s.%03d %s", strftime('%Y-%m-%dT%H:%M:%S', localtime $seconds), $microseconds / 1000, $line;
}
