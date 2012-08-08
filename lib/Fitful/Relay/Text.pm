package Fitful::Relay::Text;

require Fitful::Relay;
@ISA = qw(Fitful::Relay);

sub extend
{
	my $self = shift;

	use Fitful::Relay::Text::Options;
	$self->{"options"} = new Fitful::Relay::Text::Options;
}

# "public" method which all relay modules must implement
sub send
{
	; # NOP
}

1;
