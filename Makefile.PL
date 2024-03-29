# $Id: Makefile.PL,v 1.1 2002/05/12 17:33:43 wendigo Exp $
#
#  Copyright (c) 2000, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Makefile.PL,v $
# Revision 1.1  2002/05/12 17:33:43  wendigo
# Initial revision
#
# Revision 0.1.1.3  2001/04/11 15:58:55  ram
# patch3: now depends on Getargs::Long
#
# Revision 0.1.1.2  2000/11/12 14:53:38  ram
# patch2: changed pre-req on Log::Agent
#
# Revision 0.1.1.1  2000/11/06 19:57:50  ram
# patch1: added build_pm_hash() to compute PM value from MANIFEST
#
# Revision 0.1  2000/03/05 22:15:40  ram
# Baseline for first alpha release.
#
# $EndLog$
#

use ExtUtils::MakeMaker;
use Log::Agent;

WriteMakefile(
    'NAME'	=> 'Log::Agent::Rotate',
    'VERSION_FROM' => 'Rotate.pm', # finds $VERSION
	'PREREQ_PM' => {
		'Compress::Zlib'   => '0.4',
		'Getargs::Long'    => '0.103',
		'LockFile::Simple' => '0.202',
		'Log::Agent'       => '0.201',
	},
	'PM' => build_pm_hash(),
    'LIBS'	=> [''],		# e.g., '-lm' 
    'DEFINE'	=> '',		# e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',			# e.g., '-I/usr/include/other' 
	# 'PREFIX' => '/home/ram/usr/lib/site_perl',
);

#
# build_pm_hash
#
# Find out all the *.pm files in the MANIFEST, and build a hash ref
# containing entries like:
#
#      'file.pm'    =>  '$(INST_LIBDIR)/file.pm'
#
# for each file.
#
sub build_pm_hash {
	local *MANI;
	open(MANI, "MANIFEST") || logdie "can't open MANIFEST: $!";
	local $_;
	my @pm;
	while (<MANI>) {
		my ($file, $comment) = split;
		next unless $file =~ /\.pm$/;
		push @pm, $file;
	}
	my %pm = map { $_ => '$(INST_LIBDIR)/' . $_ } @pm;
	return \%pm;
}

