#
# $Id: code.pl,v 1.1 2002/05/12 17:33:43 wendigo Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: code.pl,v $
# Revision 1.1  2002/05/12 17:33:43  wendigo
# Initial revision
#
# Revision 0.1  2000/03/05 22:15:40  ram
# Baseline for first alpha release.
#
# $EndLog$
#

sub ok {
	my ($num, $ok) = @_;
	print "not " unless $ok;
	print "ok $num\n";
}

sub contains {
	my ($file, $pattern) = @_;
	local *FILE;
	local $_;
	open(FILE, $file) || die "can't open $file: $!\n";
	my $found = 0;
	while (<FILE>) {
		if (/$pattern/) {
			$found = 1;
			last;
		}
	}
	close FILE;
	return $found;
}

1;

