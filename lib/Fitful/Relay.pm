package Fitful::Relay;

use Carp;
# this package only lives to be extended

sub new
{
	my $self = bless {}, shift;
	$self->extend ();
	croak "Failed to read options: " . $self->{"options"}->{"error"}
		if exists $self->{"options"}->{"error"};
	$self;
}

sub name
{
	my $self = shift;
	if (@_) { $self->{"name"} = shift; }
	$self->{"name"};
}

sub options { shift->{"options"}; }

1;
