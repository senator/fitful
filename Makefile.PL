#!/usr/bin/perl

require 5.008;
use ExtUtils::MakeMaker;

WriteMakefile (
	NAME => 'fitful',
	VERSION_FROM => 'lib/Fitful.pm',
	EXE_FILES => ['bin/fitfuld'],
	AUTHOR => 'Lebbeous Fogle-Weekley',
	PREREQ_PM => {
		'Mail::Sendmail' => 0.79,
		'Config::General' => 2.31,
		'Proc::Daemon' => 0.03,
		'Net::DNS' => 0.66
	},
	ABSTRACT => 'Queue and relay single-line messages (such as from Syslog)'
);

0;
