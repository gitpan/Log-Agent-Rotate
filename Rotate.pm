#
# $Id: Rotate.pm,v 0.1 2000/03/05 22:15:40 ram Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#  
# HISTORY
# $Log: Rotate.pm,v $
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

$VERSION = '0.100';

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
#
sub make {
	my $self = bless {}, shift;
	my (%args) = @_;

	my %set = (
		-backlog	=> \$self->{'backlog'},
		-unzipped	=> \$self->{'unzipped'},
		-max_size	=> \$self->{'max_size'},
		-max_write	=> \$self->{'max_write'},
		-max_time	=> \$self->{'max_time'},
		-is_alone	=> \$self->{'is_alone'},
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

	$self->{'backlog'}		= 7			unless defined $self->{'backlog'};
	$self->{'unzipped'}		= 1			unless defined $self->{'unzipped'};
	$self->{'max_size'}		= 1_048_576	unless defined $self->{'max_size'};
	$self->{'max_write'}	= 0			unless defined $self->{'max_write'};
	$self->{'max_time'}		= 0			unless defined $self->{'max_time'};
	$self->{'is_alone'}		= 0			unless defined $self->{'is_alone'};

	return $self;
}

#
# Attribute access
#

sub backlog		{ $_[0]->{'backlog'} }
sub unzipped	{ $_[0]->{'unzipped'} }
sub max_size	{ $_[0]->{'max_size'} }
sub max_write	{ $_[0]->{'max_write'} }
sub max_time	{ $_[0]->{'max_time'} }
sub is_alone	{ $_[0]->{'is_alone'} }

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

Defaults to C<0>, meaning it is not checked.

=item I<max_write>

The maximum amount of data we can write to the logfile.  Like C<max_size>,
this is a threshold, which is only checked after a write to the logfile.
This is not the total logfile size: if several programs write to the same
logfile and C<max_size> is not used, then the logfiles may never be rotated
at all if none of the programs write at least C<max_write> bytes to the
logfile before exiting.

Defaults to C<0>, meaning it is not checked.

=item I<unzipped>

The amount of old logfiles, amongst the most recent ones, that should
not be compressed but be kept as plain files.

Defaults to 1.

=back

All the aforementionned switches have a corresponding querying routine
that can be issued on instances of the class to get their value.  It is
not possible to modify those attributes.

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
