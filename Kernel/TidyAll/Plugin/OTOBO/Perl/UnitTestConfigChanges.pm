# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.io/
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

package TidyAll::Plugin::OTOBO::Perl::UnitTestConfigChanges;

use v5.24;
use strict;
use warnings;
use utf8;

# core modules
use File::Basename;

# CPAN modules
use Moo;

# OTOBO modules

extends qw(TidyAll::Plugin::OTOBO::Perl);

our $ObjectManagerDisabled = 1;

# Make sure Selenium tests only modify the configuration via $Helper->ConfigSettingChange().

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $LineNo ) = ( '', 1 );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        next LINE unless $Line =~ m{ -> (?: SettingUpdate | SettingReset ) }smx;

        $ErrorMessage .= "Line $LineNo: $Line\n";
    }
    continue {
        $LineNo++;
    }

    return unless $ErrorMessage;

    return $Self->DieWithError(<<"EOF");
Selenium tests should modify the system configuration exclusively via
\$Helper->ConfigSettingChange(). Note that this method does not have
the same API as \$SysConfigObject->SettingUpdate().
$ErrorMessage
EOF
}

1;
