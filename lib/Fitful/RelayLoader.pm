package Fitful::RelayLoader;

# This subroutine just requires and instantations every package matching
# the glob, also telling each object what its name is (so it doesn't have
# to tell itself).

sub loadAll
{
	my $names = shift;
	my @relays;
	foreach (split / /, $names)
	{
		my $fn = "Fitful/Relay/$_.pm";
		require $fn;
		(my $packagename = $fn) =~ s{^(\w+)/(\w+)/(\w+)\.pm$}{$1::$2::$3};
		my $obj = new $packagename;
		$obj->name ($3);
		push @relays, $obj;
	}

	return @relays;
}

sub byName
{
	my $name = shift;
	foreach my $module (@_) { return $module if $module->name eq $name; }
	warn "Didn't find '$name'!";
	undef;
}

1;
