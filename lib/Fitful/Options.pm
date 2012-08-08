package Fitful::Options;

#
# This is where you do the configuration of Fitful insofar as the parts
# that need to be available to the 'fitfulr' (Fitful relay) command.  We
# 'hard-code' the configuration like this, as opposed to parsing a
# conf file, so that fitfulr will be as fast as possible.  It needs to be
# fast because syslog-ng is going to run it once for every single log
# message that it sends our way.
#

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw($FITFUL_CONF_PATH);

# This is where the configuration file path is hardcoded. Change here. Change
# nothing else.
#
our $FITFUL_CONF_PATH = '/etc/fitful';

##
# Depsite the above use of Exporter, this package is an OO class.

use Config::General;
use Carp;

sub new
{
	my $self = bless {}, shift;
	my $conf = eval { new Config::General (
		-ConfigFile => "${FITFUL_CONF_PATH}/fitful.conf",
		-DefaultConfig => {
			"relay_modules" => "Mail",
			"relay_delay" => 15000,
			"listen_host" => "localhost",
			"listen_port" => 4955,
			"pid_file" => "/var/run/fitful.pid"
		},
		-MergeDuplicateOptions => 1
	); } or croak "Couldn't parse fitful config: $@";

	$self->{"config"} = +{ $conf->getall () };
	$self;
}

sub get
{
	my ($self, $key) = @_;
	$self->{"config"}->{$key};
}

sub dump
{
	my $self = shift;
	foreach (keys %{$self->{"config"}})
	{
		print "\t$_ = ", $self->{"config"}->{$_}, "\n";
	}
}

1;
