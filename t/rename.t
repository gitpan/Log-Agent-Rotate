#!./perl

#
# $Id: rename.t,v 1.1 2002/05/12 17:33:43 wendigo Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: rename.t,v $
# Revision 1.1  2002/05/12 17:33:43  wendigo
# Initial revision
#
# Revision 0.1  2000/03/05 22:15:41  ram
# Baseline for first alpha release.
#
# $EndLog$
#

#
# Check normal behaviour, with 2 non-compressed files
#
print "1..10\n";

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
	-is_alone    => 0,
    -max_size    => 100,
);

my $driver = Log::Agent::Driver::File->make(
	-rotate   => $rotate_dflt,
	-channels => {
		'error'  => 't/logfile',
		'output' => 't/logfile',
	},
);
logconfig(-driver => $driver);

my $message = "this is a message whose size is exactly 53 characters";

logsay $message;
logwarn $message;		# will bring logsize size > 100 chars
logerr "new $message";	# not enough to rotate again

ok 1, -e("t/logfile");
ok 2, -e("t/logfile.0");
ok 3, !-e("t/logfile.1");

ok 4, rename("t/logfile", "t/logfile.0");

logsay $message;		# does not rotate, since we renamed above

ok 5, -e("t/logfile");
ok 6, -e("t/logfile.0");
ok 7, !-e("t/logfile.1");

ok 8, rename("t/logfile", "t/logfile.0");

logsay $message;
ok 9, !-e("t/logfile.1");
logsay $message;		# finally rotates
ok 10, -e("t/logfile.1");

cleanlog;

