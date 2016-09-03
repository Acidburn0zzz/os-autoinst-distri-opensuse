# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use strict;
use base "y2logsstep";
use testapi;

sub handle_login {
    if (get_var('DESKTOP_MINIMALX_INSTONLY')) {
        # return at the DM and log in later into desired wm
        return;
    }
    mouse_hide();
    wait_still_screen;
    if (get_var('DM_NEEDS_USERNAME')) {
        type_string $username;
    }
    if (match_has_tag("sddm")) {
        # make sure choose plasma5 session
        assert_and_click "sddm-sessions-list";
        assert_and_click "sddm-sessions-plasma5";
        assert_and_click "sddm-password-input";
    }
    else {
        send_key "ret";
        if (!check_screen "displaymanager-password-prompt") {
            record_soft_failure;
            assert_screen "displaymanager-password-prompt";
        }
    }
    type_string "$password";
    send_key "ret";
}

sub run() {
    my $self = shift;

    if (check_var('DESKTOP', 'textmode') || get_var('BOOT_TO_SNAPSHOT')) {
        if (!check_var('ARCH', 's390x')) {
            assert_screen 'linux-login', 200;
        }
        return;
    }

    if (get_var("NOAUTOLOGIN") || get_var("IMPORT_USER_DATA")) {
        assert_screen [qw/displaymanager emergency-shell emergency-mode/], 200;
        handle_login;
        if (match_has_tag('emergency-shell')) {
            # get emergency shell logs for bug, scp doesn't work
            script_run "cat /run/initramfs/rdsosreport.txt > /dev/$serialdev";
        }
        elsif (match_has_tag('emergency-mode')) {
            type_password;
            send_key 'ret';
        }
    }

    # 2 is not magic number here, we're using 400 seconds in the past,
    # decrease the timeout to 300 seconds now thus doing two times.
    my $retry = 2;
    # Check for errors during first boot
    while ($retry) {
        # GNOME and KDE get into screenlock after 5 minutes without activities.
        # using 300 seconds here then we can get the wrong desktop screenshot at least
        # in case desktop screenshot changed, otherwise we get the screenlock screenshot.
        my $ret = check_screen "generic-desktop", 300;
        if ($ret) {
            mouse_hide();
            last;
        }
        else {
            # special case for KDE
            if (check_var("DESKTOP", "kde")) {
                # KDE Greeter was removed from Leap 42.1 though
                if (check_screen "kde-greeter", 60) {
                    send_key "esc";
                    next;
                }
            }
        }
        $retry--;
    }
    # get the last screenshot
    assert_screen "generic-desktop", 5;
}

sub test_flags() {
    return {fatal => 1, milestone => 1};
}

sub post_fail_hook() {
    my $self = shift;

    # Reveal what is behind Plymouth splash screen
    wait_screen_change {
        send_key 'esc';
    };
    $self->export_logs();
}

1;

# vim: set sw=4 et:
