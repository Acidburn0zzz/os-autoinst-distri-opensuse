# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: move all inst/$DESKTOP.pm into one global 999_finish_desktop and runthe tests from start.pl
# Maintainer: Stephan Kulow <coolo@suse.de>

use base "installbasetest";
use testapi;
use strict;
use warnings;

# using this as base class means only run when an install is needed
sub run {
    my $self = shift;

    # live may take ages to boot
    my $timeout = 600;
    assert_screen "generic-desktop", $timeout;

}

sub post_fail_hook {
    my $self = shift;

    $self->export_logs();

    # Also list branding packages (help to debug desktop branding issues)
    $self->save_and_upload_log('zypper --no-refresh se *branding*', '/tmp/list_branding_packages.txt', {screenshot => 1});
}

1;
