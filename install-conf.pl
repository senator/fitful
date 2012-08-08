#!/usr/bin/perl

our $SRC = 'conf';
our $TARG = '/etc/fitful';

die "Run this command from the top directory of your fitful distribution.\n"
	if (! -d $SRC);

if (-d $TARG)
{
	print "Overwrite fitful configuration with defaults (y/n)? ";
	my $line = <STDIN>;
	exit 0 if $line !~ /^\s*y/i;
	system "rm -r $TARG";
}

system "cp -r $SRC $TARG";
