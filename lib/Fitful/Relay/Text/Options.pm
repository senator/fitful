package Fitful::Relay::Text::Options;

use Fitful::Options;	# for conf file path

require Fitful::Relay::Options::Options;	# we extend this class
our @ISA = qw(Fitful::Relay::Options::Options);

sub config_file_path { "${FITFUL_CONF_PATH}/modules/text.conf" };

sub default_options
{
	+{ "output_file" => "blahBLAH", "foo" => "BAR" };
}

1;
