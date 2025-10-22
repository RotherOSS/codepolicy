# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2025 Rother OSS GmbH, https://otobo.io/
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

package TidyAll::Plugin::OTOBO::JavaScript::ESLint;

use strict;
use warnings;

use Encode;
use File::Basename;
use File::Path qw(make_path remove_tree);
use File::Copy qw(copy);
use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

our $NodePath;
our $ESLintPath;

sub transform_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    if ( !$ESLintPath ) {

        # On some systems (Ubuntu) nodejs is called /usr/bin/nodejs instead of /usr/bin/node,
        #   which can lead to problems with calling the node scripts directly. Therefore we
        #   determine the nodejs binary and call it directly.
        $NodePath = `which nodejs 2>/dev/null` || `which node 2>/dev/null`;
        chomp $NodePath;
        if ( !$NodePath ) {
            die "Error: could not find the 'nodejs' binary.\n";
        }

        $ESLintPath = `which eslint 2>/dev/null`;
        chomp $ESLintPath;
        if ( !$ESLintPath ) {
            die "Error: could not find the 'eslint' script.\n";
        }

        # Force the minimum version of eslint.
        my $ESLintVersion = `$NodePath $ESLintPath -v`;
        chomp $ESLintVersion;
        my ( $Major, $Minor, $Patch ) = $ESLintVersion =~ m{v(\d+)[.](\d+)[.](\d+)};
        my $Compare = sprintf( "%03d%03d%03d", $Major, $Minor, $Patch );
        if ( !length($Major) || $Compare < 9_000_000 ) {
            undef $ESLintPath;    # Make sure to re-issue this error for future files.
            die "Error: your eslint version ($ESLintVersion) is outdated.\n";
        }
    }

    my $ESLintConfigPath = __FILE__;
    $ESLintConfigPath =~ s{ESLint\.pm}{ESLint/eslint.config.mjs};

    # create file symlink or copy to prevent eslint 9.x error "File ignored because outside of base path"
    my $TmpFilePath = $ESLintConfigPath;
    $TmpFilePath =~ s{/[^/]+$}{};
    $TmpFilePath .= "/tmp/";
    make_path($TmpFilePath, {error => \my $err});
    if ($err && @$err) {
        die "Can't create temporary directory at $TmpFilePath \n Error: " . join(", ", @$err) . "\n ";
    }
    $TmpFilePath .= basename($Filename);
    symlink($Filename, $TmpFilePath) 
        or copy("sourcefile", "destinationfile") 
        or die "Can't create symlink or copy of $Filename at $TmpFilePath";

    my $Command = sprintf(
        "%s %s -c %s --fix %s",
        $NodePath, $ESLintPath, $ESLintConfigPath, $TmpFilePath
    );

    my $Output = `$Command`;

    # remove temporary symlink or copy
    remove_tree($TmpFilePath) or 
        die "Can't remove symlink or copy of file $Filename at $TmpFilePath";

    if ( ${^CHILD_ERROR_NATIVE} || $Output ) {
        Encode::_utf8_on($Output);
        return $Self->DieWithError("$Output\n");
    }
}

1;
