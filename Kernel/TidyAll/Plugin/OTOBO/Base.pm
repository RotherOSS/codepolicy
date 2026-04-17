# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2026 Rother OSS GmbH, https://otobo.io/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package TidyAll::Plugin::OTOBO::Base;

use strict;
use warnings;
use v5.24;
use utf8;

use Moo;

extends qw(Code::TidyAll::Plugin);

use TidyAll::OTOBO;

use IO::Interactive qw(is_interactive);
use Term::ANSIColor qw(colored);

sub IsPluginDisabled {
    my ( $Self, %Param ) = @_;

    my $PluginPackage = ref $Self;

    if ( !defined $Param{Code} && !defined $Param{Filename} ) {
        print STDERR "Need Code or Filename!\n";
        die;
    }

    my $Code = defined $Param{Code} ? $Param{Code} : $Self->_GetFileContents( $Param{Filename} );

    if ( $Code =~ m{nofilter\([^()]*\Q$PluginPackage\E[^()]*\)}ismx ) {
        return 1;
    }

    return;
}

sub IsFrameworkVersionLessThan {
    my ( $Self, $FrameworkVersionMajor, $FrameworkVersionMinor ) = @_;

    if ($TidyAll::OTOBO::FrameworkVersionMajor) {
        return 1 if $TidyAll::OTOBO::FrameworkVersionMajor < $FrameworkVersionMajor;
        return 0 if $TidyAll::OTOBO::FrameworkVersionMajor > $FrameworkVersionMajor;
        return 1 if $TidyAll::OTOBO::FrameworkVersionMinor < $FrameworkVersionMinor;
        return 0;
    }

    # Default: if framework is unknown, return false (strict checks).
    return 0;
}

sub IsThirdpartyModule {
    my ($Self) = @_;

    return $TidyAll::OTOBO::ThirdpartyModule ? 1 : 0;
}

sub DieWithError {
    my ( $Self, $Error ) = @_;

    chomp $Error;

    die colored( ref($Self), 'yellow' ) . "\n" . colored( $Error, 'red' ) . "\n";
}

sub _GetFileContents {
    my ( $Self, $Filename ) = @_;

    open( my $FileHandle, '<', $Filename ) || die "Can't open $Filename\n";    ## no critic qw(OTOBO::ProhibitOpen)

    #    my $FileHandle;
    #    if ( !open $FileHandle, '<', $Filename ) {    ## no critic qw(OTOBO::ProhibitOpen)
    #        print STDERR "Can't open $Filename\n";
    #        die;
    #    }

    my $Content = do { local $/ = undef; <$FileHandle> };
    close $FileHandle;

    return $Content;
}

1;
