#!./perl

#
# $Id: normal.t,v 1.1 2002/05/12 17:33:43 wendigo Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: normal.t,v $
# Revision 1.1  2002/05/12 17:33:43  wendigo
# Initial revision
#
# Revision 0.1.1.2  2001/04/11 16:00:55  ram
# patch3: ensure logfile rotation indication is left properly
#
# Revision 0.1.1.1  2000/11/12 14:54:26  ram
# patch2: use new -single_host parameter
#
# Revision 0.1  2000/03/05 22:15:41  ram
# Baseline for first alpha release.
#
# $EndLog$
#

#
# Check normal behaviour, with 2 non-compressed files
#
print "1..21\n";

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
	-single_host => 1,
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

logsay $message;		# rotates, creates logfile.1
logsay $message;
logsay $message;		# rotates again, now has logfile.2.gz, no logfile

ok 4, !-e("t/logfile");
ok 5, -e("t/logfile.0");
ok 6, -e("t/logfile.1");
ok 7, -e("t/logfile.2.gz");
ok 8, !-e("t/logfile.3.gz");

logsay $message;		# creates a logfile
ok 9, -e("t/logfile");

logsay $message;		# rotates again, now has logfile.3.gz
logsay $message;
logsay $message;		# rotates again, now has logfile.4.gz
logsay $message;
logsay $message;		# rotates again, now has logfile.5.gz
logsay $message;
logsay $message;		# rotates again, now has logfile.6.gz
logsay $message;
logsay $message;		# rotates again, no logfile.7.gz

ok 10, !-e("t/logfile");
ok 11, -e("t/logfile.0");
ok 12, -e("t/logfile.1");
ok 13, -e("t/logfile.2.gz");
ok 14, -e("t/logfile.3.gz");
ok 15, -e("t/logfile.4.gz");
ok 16, -e("t/logfile.5.gz");
ok 17, -e("t/logfile.6.gz");
ok 18, !-e("t/logfile.7.gz");

logsay $message;
logsay $message;		# rotates again, sill no logfile.7.gz

ok 19, -e("t/logfile.6.gz");
ok 20, !-e("t/logfile.7.gz");
ok 21, contains("t/logfile.0", "LOGFILE ROTATED ON");

cleanlog;

