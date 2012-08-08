package Fitful::Relay::Options::Options;

# This package can not work by itself.  It is extended by packages
# Fitful::Relay::*::Options.

use Config::General;
use Carp;

sub new
{
	my $self = bless {}, shift;
	my $conf = eval { new Config::General (
		-ConfigFile => $self->config_file_path (),
		-DefaultConfig => $self->default_options (),
		-MergeDuplicateOptions => 1
	); } or croak "Module conf parse failed: $@";
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
