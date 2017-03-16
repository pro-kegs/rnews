#!/usr/bin/perl -w
use strict;
use Getopt::Long;

use MIME::QuotedPrint;
use MIME::Base64;
use HTML::FormatText;


use constant HEADERS => qw(
	Date
	From
	Subject
	Newsgroups
	Summary
	Keywords
	Message-ID
	Followup-To
	References
	Sender
	Reply-To
	Distribution
	Organization
);
# Lines is obsolete and cleanup_body will change it anyhow



#
# handle html content-type and quoted-printable encoding.
# also wrap lines > 79 characters.
#
sub cleanup_body($$$) {
	my ($body, $type, $encoding) = @_;

	my $html = ($type =~ m#text/html#i);
	my $qp = ($encoding =~ m/quoted-printable/i);

	$body = decode_qp($body)
		if ($encoding =~ m/quoted-printable/i);

	$body = HTML::FormatText->format_string($body, leftmargin => 0, rightmargin => 72)
		if ($type =~ m#text/html#i);


	# strip non-ascii characters
	# strip control chars too? (except \n\t)
	$body =~ s/[\x80-\xff]//g;

	# make sure lines are < 80 chars
	my @lines = split("\n", $body);


	# remove blank lines at the end.
	# also remove "Link" if this is html (from rss)
	while (scalar @lines) {
		$_ = $lines[$#lines];

		if ($_ =~ m/^\s*$/) {
			pop @lines;
			next;
		}
		if ($html && $_ eq 'Link') {
			pop @lines;
			next;
		}
		last;
	}

	my @tmp;

	foreach my $x (@lines) {
		# removing trailing ws
		$x =~ s/\s+$//g;
		while (length($x) > 80) {
			my $pos = index($x, " ", 72);
			$pos = 72 if ($pos < 0 || $pos > 79);
			my $chunk = substr($x, 0, $pos);
			$x = substr($x, $pos);
			$x =~ s/^\s+//g;
			push(@tmp, $chunk) unless $chunk =~ m/^\s*$/;
		}
		push(@tmp, $x);
	}

	return join("\n", @tmp);
}

#
# fix rfc 1342 encoding in the subject.
#
sub cleanup_subject($) {

	# rfc 1342
	# =charset?encoding?encoded-text?=
	# encoding is Q or B
	# charset could be anything but it's probably utf8

	# rfc 1342
	my ($value) = @_;

	$value =~ s/^\s+|\s+$//g;

	if ($value =~ m/^=\?UTF-8\?([QB])\?(.*)\?=$/i) {
		$value = $2;
		my $e = $1;

		$value = decode_qp($value) if $e eq 'Q';
		$value = decode_base64($value) if $e eq 'B';
	}
	$value =~ s/[\x80-\xff]//g;
	return $value;
}


# to reduce the file size, extra headers are removed.
my %headers;
foreach (HEADERS) { $headers{uc $_} = 1; }

my $test = 0;
my $verbose = 0;
GetOptions( "test" => \$test, "verbose" => \$verbose);

#print $ARGV[0], "\n";
my $dir = $ARGV[0] or die "Input directory missing.";


opendir (my $dh, $dir) or die "Can't open $dir";
# get list of files, skipping hidden files
my @files = grep ( !/^\./, readdir($dh));
closedir $dh;

foreach my $file (@files) {

	#print $file, "\n";
	# read the file in
	my $path  = "${dir}/${file}";
	my $fh;
	open ($fh, "<", $path) or die "Can't read ${path}\n";
	my @file = <$fh>;
	close $fh;

	my @body;
	my @head;

	my $state = 0;
	my $ce = '';
	my $ct = '';

	foreach my $line (@file) {
		chomp($line);
		if ($state == 0 && $line eq '') {
			$state = 1;
			next;
		}
		if ($state == 0) {
			next if ($line =~ /^\s+/); # continuation of previous line...
			if ($line =~m /^([A-Za-z_0-9-]+):\s+(.*)$/) {
				my $key = uc $1;
				my $value = $2;

				$ce = $value if ($key eq 'CONTENT-TRANSFER-ENCODING');
				$ct = $value if ($key eq 'CONTENT-TYPE');

				if ($key eq 'SUBJECT') {
					$line = "Subject: " . cleanup_subject($value);
				}

				push @head, $line if ($headers{$key});
			}
			next;
		}

		# body!
		push @body, $line;
	}



	# save it back out

	my $head = join("\n", @head) . "\n";
	my $body = join("\n", @body) . "\n";
	$body = cleanup_body($body, $ct, $ce);

	if ($test) {
		print $head, "\n", $body, "\n";
	} else {
		open ($fh, ">", $path) or die "Can't write to ${path}\n";
		print $fh $head, "\n", $body, "\n";
		close $fh;
	}
}
exit 0;
