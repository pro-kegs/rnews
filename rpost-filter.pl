#!/usr/bin/perl -w
use strict;
use Getopt::Long;


use constant HEADERS => qw(
	Path
	Date
	From
	Subject
	Newsgroups
	Distribution
	Organization
	In-Reply-To
);

my %headers;
foreach (HEADERS) { $headers{uc $_} = 1; }


my $test = 0;
my $verbose = 0;

GetOptions( "test" => \$test, "verbose" => \$verbose);

my @out;
my $state = 0;

foreach my $line (<>) {
	chomp($line);
	if ($state == 0 && $line eq '') {
		$state = 1;
	}

	if ($state == 0) {

		if ($line =~ m/^([A-Za-z_0-9-]+):\s+(.*)$/) {
			my $key = uc $1;
			my $value = $2;

			next unless $headers{$key};

			# special case for fixing From
			# From: pro-kegs!kelvin
			if ($key eq 'FROM') {

				#$line = 'From: kelvin@proline.ksherlock.com';
				if ($value =~ m/^([-A-Za-z0-9_.]+)!([-A-Za-z0-9_.]+)/) {
					$line = "From: $2" . "@" . "$1" ".proline"
				}
			}
		} else {
			next;
		}

	}

	push @out, $line
}

print join("\n", @out), "\n";
exit 0;
