#!perl
###########################################################################
# $Id: perm.t,v 1.1 2002/05/14 04:46:34 wendigo Exp $
###########################################################################
#
# perm.t
#
# RCS Revision: $Revision: 1.1 $
# Date: $Date: 2002/05/14 04:46:34 $
#
# Copyright (c) 2002 Mark Rogaski, mrogaski@cpan.org; all rights reserved.
#
# See the README file included with the
# distribution for license information.
#
# $Log: perm.t,v $
# Revision 1.1  2002/05/14 04:46:34  wendigo
# Initial revision
#
#
###########################################################################
use Test;

BEGIN { plan tests => 4 }

use Log::Agent;
require Log::Agent::Driver::File;
require Log::Agent::Rotate;

sub clear_log () {
    unlink <t/logfile*>;
}

sub perm_ok ($$) {
    #
    # Given a fileame and target permissions, checks if the file
    # was created with the correct permissions.
    #
    my($file, $target) = @_;

    $target &= ~ umask;         # account for user mask
    my $mode = (stat $file)[2]; # find the current mode
    $mode &= 0777;              # we only care about UGO

    return $mode == $target;
}


my $rotate = Log::Agent::Rotate->make(
    -backlog     => 2,
    -unzipped    => 2,
    -is_alone    => 1,
    -single_host => 1,
    -max_size    => 100,
    -file_perm   => 0600
);

my $driver = Log::Agent::Driver::File->make(
    -rotate   => $rotate,
    -channels => {
        'error'  => 't/logfile',
        'output' => 't/logfile',
    },
);

my $msg = '!' x 55;

logconfig(-driver => $driver);
clear_log;

logsay $msg;
ok(perm_ok("t/logfile", 0600));
logsay $msg;
ok(perm_ok("t/logfile.0", 0600));

$rotate = Log::Agent::Rotate->make(
    -backlog     => 2,
    -unzipped    => 2,
    -is_alone    => 1,
    -single_host => 1,
    -max_size    => 100,
    -file_perm   => 0644
);

$driver = Log::Agent::Driver::File->make(
    -rotate   => $rotate,
    -channels => {
        'error'  => 't/logfile',
        'output' => 't/logfile',
    },
);

logconfig(-driver => $driver);
clear_log;

logsay $msg;
ok(perm_ok("t/logfile", 0644));
logsay $msg;
ok(perm_ok("t/logfile.0", 0644));

clear_log;
 
