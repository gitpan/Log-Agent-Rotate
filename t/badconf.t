#!./perl

#
# $Id: badconf.t,v 1.1 2002/05/12 17:33:43 wendigo Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: badconf.t,v $
# Revision 1.1  2002/05/12 17:33:43  wendigo
# Initial revision
#
# Revision 0.1.1.1  2000/11/06 20:04:10  ram
# patch1: updated test to new logic
#
# Revision 0.1  2000/03/05 22:15:40  ram
# Baseline for first alpha release.
#
# $EndLog$
#

#
# Ensure possible incorrect rotation is detected whith bad Log::Agent config
#
print "1..6\n";

require 't/code.pl';
sub ok;

sub cleanlog() {
	unlink <t/logfile*>;
}

use Log::Agent;
require Log::Agent::Driver::File;
require Log::Agent::Rotate;

cleanlog;
my $rotate_dflt = Log::Agent::Rotate->make(
	-backlog     => 7,
	-unzipped    => 2,
	-is_alone    => 1,
    -max_size    => 100,
);

my $rotate_other = Log::Agent::Rotate->make(
	-backlog     => 7,
	-unzipped    => 1,
	-is_alone    => 1,
    -max_size    => 100,
);

my $driver = Log::Agent::Driver::File->make(
	-rotate   => $rotate_dflt,
	-channels => {
		'error'  => ['t/logfile', $rotate_other],
		'output' => 't/logfile',
	},
);
logconfig(-driver => $driver);

my $message = "this is a message whose size is exactly 53 characters";

logsay $message;
logwarn $message;		# will bring logsize size > 100 chars

ok 1, -e("t/logfile");
ok 2, -e("t/logfile.0");
ok 3, contains("t/logfile.0", "Rotation for 't/logfile' may be wrong");

cleanlog;
undef $Log::Agent::Driver;		# Cheat

$driver = Log::Agent::Driver::File->make(
	-rotate   => $rotate_dflt,
	-channels => {
		'error'  => ['t/logfile', $rotate_dflt],
		'output' => 't/logfile',
	},
);
logconfig(-driver => $driver);

logsay $message;
logwarn $message;		# will bring logsize size > 100 chars

ok 4, !-e("t/logfile");
ok 5, -e("t/logfile.0");
ok 6, !contains("t/logfile.0", "Rotation for 'error' may be wrong");

cleanlog;

