#
# $Id: Rotate.pm,v 0.1.1.2 2000/11/12 14:54:10 ram Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#  
# HISTORY
# $Log: Rotate.pm,v $
# Revision 0.1.1.2  2000/11/12 14:54:10  ram
# patch2: new -single_host parameter
#
# Revision 0.1.1.1  2000/11/06 20:03:35  ram
# patch1: moved to an array representation for the object
# patch1: added ability to specify -max_time in other units than seconds
# patch1: added is_same() to compare configurations
#
# Revision 0.1  2000/03/05 22:15:40  ram
# Baseline for first alpha release.
#
# $EndLog$
#

use strict;

########################################################################
package Log::Agent::Rotate;

#
# File rotating policy
#

use vars qw($VERSION);

$VERSION = '0.102';

BEGIN {
	sub BACKLOG ()		{0}
	sub UNZIPPED ()		{1}
	sub MAX_SIZE ()		{2}
	sub MAX_WRITE ()	{3}
	sub MAX_TIME ()		{4}
	sub IS_ALONE ()		{5}
	sub SINGLE_HOST ()	{6}
}

#
# ->make
#
# Creation routine.
#
# Attributes:
#   backlog       amount of old files to keep (0 for none)
#   unzipped      amount of old files to NOT compress (defaults to 1)
#   max_size      maximum amount of bytes in file
#   max_write     maximum amount of bytes to write in file
#   max_time      maximum amount of time to keep open
#   is_alone      hint: only one instance is busy manipulating the logfiles
#   single_host   hint: access to logfiles always made via one host
#
sub make {
	my $self = bless [], shift;
	my (%args) = @_;

	my %set = (
		-backlog		=> \$self->[BACKLOG],
		-unzipped		=> \$self->[UNZIPPED],
		-max_size		=> \$self->[MAX_SIZE],
		-max_write		=> \$self->[MAX_WRITE],
		-max_time		=> \$self->[MAX_TIME],
		-is_alone		=> \$self->[IS_ALONE],
		-single_host	=> \$self->[SINGLE_HOST],
	);

	while (my ($arg, $val) = each %args) {
		my $vset = $set{lc($arg)};
		unless (ref $vset) {
			require Carp;
			Carp::croak("Unknown switch $arg");
		}
		$$vset = $val;
	}

	#
	# Setup default values.
	#

	$self->[BACKLOG]     = 7			unless defined $self->[BACKLOG];
	$self->[UNZIPPED]    = 1			unless defined $self->[UNZIPPED];
	$self->[MAX_SIZE]    = 1_048_576	unless defined $self->[MAX_SIZE];
	$self->[MAX_WRITE]   = 0			unless defined $self->[MAX_WRITE];
	$self->[MAX_TIME]    = 0			unless defined $self->[MAX_TIME];
	$self->[IS_ALONE]    = 0			unless defined $self->[IS_ALONE];
	$self->[SINGLE_HOST] = 0			unless defined $self->[SINGLE_HOST];

	$self->[MAX_TIME] = seconds_in_period($self->[MAX_TIME])
		if $self->[MAX_TIME];

	return $self;
}

#
# seconds_in_period
#
# Converts a period into a number of seconds.
#
sub seconds_in_period {
	my ($p) = @_;

	$p =~ s|^(\d+)||;
	my $base = int($1);			# Number of elementary periods
	my $u = "s";				# Default Unit
	$u = substr($1, 0, 1) if $p =~ /^\s*(\w+)$/;
	my $sec;

	if ($u eq 'm') {
		$sec = 60;				# One minute = 60 seconds
	} elsif ($u eq 'h') {
		$sec = 3600;			# One hour = 3600 seconds
	} elsif ($u eq 'd') {
		$sec = 86400;			# One day = 24 hours
	} elsif ($u eq 'w') {
		$sec = 604800;			# One week = 7 days
	} elsif ($u eq 'M') {
		$sec = 2592000;			# One month = 30 days
	} elsif ($u eq 'y') {
		$sec = 31536000;		# One year = 365 days
	} else {
		$sec = 1;				# Unrecognized: defaults to seconds
	}

	return $base * $sec;
}

#
# Attribute access
#

sub backlog		{ $_[0]->[BACKLOG] }
sub unzipped	{ $_[0]->[UNZIPPED] }
sub max_size	{ $_[0]->[MAX_SIZE] }
sub max_write	{ $_[0]->[MAX_WRITE] }
sub max_time	{ $_[0]->[MAX_TIME] }
sub is_alone	{ $_[0]->[IS_ALONE] }
sub single_host	{ $_[0]->[SINGLE_HOST] }

#
# There's no set_xxx() routines: those objects are passed by reference and
# never "expanded", i.e. passed by copy.  Modifying any of the attributes
# would then lead to strange effects.
#

#
# ->is_same
#
# Compare settings of $self with that of $other
#
sub is_same {
	my $self = shift;
	my ($other) = @_;
	for (my $i = 0; $i < @$self; $i++) {
		return 0 if $self->[$i] != $other->[$i];
	}
	return 1;
}

1;	# for require
__END__

=head1 NAME

Log::Agent::Rotate - parameters for logfile rotation

=head1 SYNOPSIS

 require Log::Agent::Rotate;

 my $policy = Log::Agent::Rotate->make(
	 -backlog     => 7,
	 -unzipped    => 2,
	 -is_alone    => 0,
	 -max_size    => 100_000,
	 -max_time    => "1w",
 );

=head1 DESCRIPTION

The C<Log::Agent::Rotate> class holds the parameters describing the logfile
rotation policy, and is meant to be supplied to instances of
C<Log::Agent::Driver::File> via arguments in the creation routine,
such as C<-rotate>, or by using array references as values in the
C<-channels> hashref: See complementary information in
L<Log::Agent::Driver::File>.

As rotation cycles are performed, the current logfile is renamed, and
possibly compressed, until the maximum backlog is reached, at which time
files are deleted.  Assuming a backlog of 5 and that the latest 2 files
are not compressed, the following files can be present on the filesystem:

    logfile           # the current logfile
    logfile.0         # most recently renamed logfile
    logfile.1
    logfile.2.gz
    logfile.3.gz
    logfile.4.gz      # oldest logfile, unlinked next cycle

The following I<switches> are available to the creation routine make(),
listed in alphabetical order, all taking a single integer value as argument:

=over

=item I<backlog>

The total amount of old logfiles to keep, besides the current logfile.

Defaults to 7.

=item I<is_alone>

The argument is a boolean stating whether the program writing to the logfile
will be the only one or not.  This is a hint that drives some optimizations,
but it is up to the program to B<guarantee> that noone else will be able to
write to or unlink the current logfile when set to I<true>.

Defaults to I<false>.

=item I<max_size>

The maximum logfile size.  This is a threshold, which will cause
a logfile rotation cycle to be performed, when crossed after a write to
the file.  If set to C<0>, this threshold is not checked.

Defaults to 1 megabyte.

=item I<max_time>

The maximum time in seconds between the moment we opened the file and
the next rotation cycle occurs.  This threshold is only checked after
a write to the file.

The value can also be given as a string, postfixed by one of the
following letters to specify the period unit (e.g. "3w"):

    Letter   Unit
    ------   -------
       m     minutes
       h     hours
       d     days
       d     days
       w     weeks
       M     months (30 days of 24 hours)
       y     years

Defaults to C<0>, meaning it is not checked.

=item I<max_write>

The maximum amount of data we can write to the logfile.  Like C<max_size>,
this is a threshold, which is only checked after a write to the logfile.
This is not the total logfile size: if several programs write to the same
logfile and C<max_size> is not used, then the logfiles may never be rotated
at all if none of the programs write at least C<max_write> bytes to the
logfile before exiting.

Defaults to C<0>, meaning it is not checked.

=item I<single_host>

The argument is a boolean stating whether the access to the logfiles
will be made from one single host or not.  This is a hint that drives some
optimizations, but it is up to the program to B<guarantee> that it is
accurately set.

Defaults to I<false>, which is always a safe value.

=item I<unzipped>

The amount of old logfiles, amongst the most recent ones, that should
not be compressed but be kept as plain files.

Defaults to 1.

=back

To test whether two configurations are strictly identical, use is_same(),
as in:

    print "identical\n" if $x->is_same($y);

where both $x and $y are C<Log::Agent::Rotate> objects.

All the aforementionned switches also have a corresponding querying
routine that can be issued on instances of the class to get their value.
It is not possible to modify those attributes.

For instance:

    my $x = Log::Agent::Rotate->make(...);
    my $mwrite = $x->max_write();

would get the configured I<max_write> threshold.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

Log::Agent(3), Log::Agent::Driver::File(3),
Log::Agent::Rotate::File(3).

=cut
