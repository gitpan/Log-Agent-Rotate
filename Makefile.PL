# $Id: Makefile.PL,v 0.1 2000/03/05 22:15:40 ram Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Makefile.PL,v $
# Revision 0.1  2000/03/05 22:15:40  ram
# Baseline for first alpha release.
#
# $EndLog$
#

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	=> 'Log::Agent::Rotate',
    'VERSION_FROM' => 'Rotate.pm', # finds $VERSION
	'PREREQ_PM' => {
		'LockFile::Simple' => '0.202',
		'Compress::Zlib'   => '0.4',
		'Log::Agent'       => '0.103',
	},
	'PM' => {
		'Rotate.pm'			=> '$(INST_LIBDIR)/Rotate.pm',
		'File/Rotate.pm'	=> '$(INST_LIBDIR)/File/Rotate.pm',
	},
    'LIBS'	=> [''],		# e.g., '-lm' 
    'DEFINE'	=> '',		# e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',			# e.g., '-I/usr/include/other' 
	# 'PREFIX' => '/home/ram/usr/lib/site_perl',
);

