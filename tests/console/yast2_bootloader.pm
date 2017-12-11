# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Basic test for yast2 bootloader
# Maintainer: Oliver Kurz <okurz@suse.de>

use base "console_yasttest";
use strict;
use testapi;
use utils;

sub run {
    select_console 'root-console';

    # make sure yast2 bootloader module is installed
    zypper_call 'in yast2-bootloader';

    script_run("yast2 bootloader; echo btld-status-\$? > /dev/$serialdev", 0);
    assert_screen "test-yast2_bootloader-1", 300;
    send_key "alt-o";    # OK => Close
    assert_screen([qw(yast2_bootloader-missing_package yast2_console-finished)], 200);
    if (match_has_tag('yast2_bootloader-missing_package')) {
        wait_screen_change { send_key 'alt-i'; };
    }
    assert_screen 'yast2_console-finished', 200;
    wait_serial("btld-status-0") || die "'yast2 bootloader' didn't finish";
}

1;
# vim: set sw=4 et:
