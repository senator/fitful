package Fitful::Relay::Mail::Options;

use Fitful::Options;

require Fitful::Relay::Options::Options;
our @ISA = qw(Fitful::Relay::Options::Options);

sub config_file_path { "${FITFUL_CONF_PATH}/modules/mail.conf" };

sub default_options
{
	+{
		"smtp"	=> "localhost",
		"to" => 'root@localhost',
		"from" => 'root@localhost',
		"subject_prefix" => "syslog:"
	};
}

1;
