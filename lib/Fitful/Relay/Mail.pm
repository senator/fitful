package Fitful::Relay::Mail;

use Fitful;
use Mail::Sendmail qw(%mailcfg sendmail);
use Carp;

require Fitful::Relay;
@ISA = qw(Fitful::Relay);

sub extend
{
	my $self = shift;

	use Fitful::Relay::Mail::Options;
	$self->{"options"} = new Fitful::Relay::Mail::Options;
}

# "public" method which all relay modules must implement
sub send
{
	my ($self, $listref, $prepend) = @_;

	my $n = int (scalar (@{$listref}));
	return if $n < 1;	# nothing to do if no messages

	# Here is where we sort the messages uniquely.
	# This should move to a private method?
	my ($subject, $message) = $self->_uniqify ($listref);
	$message = $prepend . $message if defined $prepend;

	# kludge alert: we're passing the bool result of 'defined $prepend' below
	# as an 'isurgent' flag to the _sendmail method
	eval { $self->_sendmail ($message, $subject, defined $prepend) }
		or do { $fitfuld::should_quit = 1; croak "sending mail failed: $@" };
}

# "private" methods
sub _sendmail
{
	my ($self, $msg, $subject, $urg) = @_;

	$mailcfg{"mime"} = 0;	# imported package global
	# 'sendmail' subroutine auto exported by Mail::Sendmail
	my %hash = (
		smtp => $self->options->get ("smtp"),
		To => $self->options->get ("to"),
		From => $self->options->get ("from"),
		Subject => $subject,
		'X-Mailer' => "fitful $Fitful::VERSION",
		message => $msg
	);
	$hash{"X-Priority"} = "1 (Highest)" if $urg;
	sendmail (%hash)
		or die "Mail::Sendmail::sendmail failed: $Mail::Sendmail::error";
}

sub _parse_ip
{
	my ($self, $msg) = @_;

	my ($hn) = ($msg =~ /\(([^\s\)]+)\)\]/)[0];
	return $hn if defined $hn;

	my ($ip) = ($msg =~ /\[(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) /)[0];
	return $ip if defined $ip;

	undef;
}

sub _gen_subject
{
	my $self = shift;
	my $prefix = $self->options->get ("subject_prefix");

	return "$prefix " . join (", ", @_) if @_ <= 5;
	return "$prefix Unknown source(s)" if @_ < 1;
	return "$prefix Multiple sources";
}

sub _remove_redundant_ip
{
	my ($self, $string) = @_;

	my @parts = ($string =~ /^(.+)\[([\d\.]+) \(([\d\.]+)\)\](.+)$/);

	if (@parts == 4)
	{
		if ($parts[1] eq $parts[2])
		{
			return $parts[0] . "[" . $parts[1] . "]" . $parts[3] . "\n";   # skip 2
		}
	}
	return $string;
}

sub _uniqify
{
	my ($self, $listref) = @_;

	my $n = 0;
	my $message = '';
	my %seen_ip = ();
	my %seen = ();
	foreach (@{$listref})
	{
		my $ip;
		if (defined ($ip = $self->_parse_ip ($_)))
		{
			$seen_ip{$ip} = 1;
		}
		if (!$seen{$_})
		{
			$seen{$_} = 1;
			# Here we have to add a tab right before EOL for Outlook
			# users, because Outlook is TOTAL CRAP! ARGGGH!
			# Shawn: thanks for the help finding the bug!
			(my $bit = $_) =~ s/\n/\t\n/g;
			$bit = $self->_remove_redundant_ip ($bit);
			$message .= $bit;
		}
		$n++;
	}
	my $header = sprintf ("%d syslog message%s", $n, $n == 1 ? '' : 's');
	my $m = scalar keys %seen;
	if ($n > $m)
	{
		$header .= sprintf (",\r\nreduced to %d unique message%s:\r\n\r\n",
			$m, $m == 1 ? '' : 's');
	}
	else { $header .= ":\r\n\r\n"; }

	# combine generated message parts
	return ($self->_gen_subject (keys %seen_ip), $header . $message);

}

1;
