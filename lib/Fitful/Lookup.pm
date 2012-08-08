package Fitful::Lookup;

use strict;
use warnings;

use Net::DNS;

# Given a reference to a list of log messags, return a hash whose keys are IPs
# and whose values are references to the strings in which those IPs are found.
sub uniq_ips {
    my ($lines, $limit) = @_;

    my $i = 0;
    my %hash = ();
    foreach (@$lines) {
        /^.+\[([\d\.]+)/ or next;
        $hash{$1} ||= [];
        push @{$hash{$1}}, \$_;
        last if scalar (keys %hash) >= $limit;
    }

    return \%hash;
}

# $queue is a reference to the list of log lines.  Change them by replacing
# IPs with DNS names when possible.
sub lookup_rdns {
    my ($queue, $line_limit, $timeout) = @_;

    # keys of the resulting hash here are uniqified IPs
    my $ip_map = uniq_ips($queue, $line_limit);

    my $resolver = new Net::DNS::Resolver;

    # $sock as the key of this hash will be stringified, and that's why
    # we need it again in the value of the hash
    my %socks = map {
        my $sock = $resolver->bgsend($_, "PTR");
        $sock => [$_, $sock]
    } (keys %$ip_map);

    my $sel = new IO::Select(map { $socks{$_}[1] }(keys %socks));
    while (my @ready = $sel->can_read($timeout)) {
        foreach my $sock (@ready) {
            my $ip = $socks{$sock}[0];
            my @answers = $resolver->bgread($sock)->answer;
            if (@answers) {
                (my $name = $answers[0]->rdatastr) =~ s/\.$//;
                my $lines = $ip_map->{$ip};
                foreach my $line_ref (@$lines) {
                    $$line_ref =~ s/$ip/$name/; # just once
                }
            }

            $sel->remove($sock);
        }
    }
}

1;
