package Fitful::SyslogListener;

use threads;
use threads::shared;

use Carp;
use IO::Socket;
use IO::Select;

use constant {
	SELECT_WAIT_TIME => 0.05,
	MAX_LINE_LENGTH => 4097	# include <LF>
};

sub syslog_error
{
	my $error = shift;
	lock @fitfuld::errors;
	push @fitfuld::errors, "syslog listener: $error";
	$fitfuld::should_quit = 1;
}

sub syslog_check_fifo
{
	-p shift;
}

sub syslog_main
{
	my $options = shift;
	my $line;

	my $listen_socket = new IO::Socket::INET (
		LocalHost => $options->get ("listen_host"),
		LocalPort => int ($options->get ("listen_port")),
		Proto => "tcp",
		Listen => 16,
		Reuse => 1
	) or do { syslog_error ("Couldn't create listener socket: $!"); return 1 };

	my $selector = new IO::Select
		or do { syslog_error ("Couldn't create selector: $!"); return 1 };

	$selector->add ($listen_socket);

	for (;;)
	{
		if ($fitfuld::should_quit)
		{
			close $listen_socket;
			return 1;
		}

		foreach my $ready ($selector->can_read (SELECT_WAIT_TIME))
		{
			# Something is ready to do...
			if ($ready == $listen_socket)
			{
				# New connection
				$selector->add ($ready->accept);
			}
			else
			{
				# Data may be available on open connection
				$line = '';
				if (sysread $ready, $line, MAX_LINE_LENGTH)
				{
					# Data indeed is available
					my @lines = map { $_ . "\n" } split /\n/, $line;

					# FIXME: handle partial line reads better. may not
					# be too common in practice, but then again it may.

					lock @fitfuld::queue;
					push @fitfuld::queue, @lines;
				}
				else
				{
					# A connection has closed
					$selector->remove ($ready);
					close $ready;
				}
			}
		}
	}

	# the above loop never actually exists to this point
	0;
}

1;
