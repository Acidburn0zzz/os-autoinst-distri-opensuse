package caasp_controller;
use base "opensusebasetest";

use strict;
use testapi;
use lockapi;
use mmapi 'wait_for_children';

use Exporter 'import';
our @EXPORT = qw(confirm_insecure_https velum_login switch_to);

# Easier switching between applications
sub switch_to {
    my $app = shift;
    send_key_until_needlematch "switch-to-$app", 'alt-tab', 1;
}

# Register and login to velum and dex
sub velum_login {
    my $register = shift;

    type_string 'email@email.com';
    send_key 'tab';
    type_string 'password';
    if ($register) {
        send_key 'tab';
        type_string 'password';
    }
    sleep 1;
    save_screenshot;
    send_key 'ret';
}

# Users have to confirm certificate 3 times during deployment
sub confirm_insecure_https {
    wait_still_screen 3;
    assert_and_click 'velum-https-advanced';
    assert_and_click 'velum-https-add_exception';
    assert_and_click 'velum-https-confirm';
}

# Base class for CaaSP tests
sub test_flags {
    return {fatal => 1};
}

# Controller job is parent. If it fails we need to export deployment logs from child jobs
# Without this post_fail_hook they would stop with parallel_failed result
sub post_fail_hook {
    # Variable to enable failed cluster debug
    sleep if check_var('DEBUG_SLEEP', 'controller');

    # Destroy barriers and create mutexes to avoid deadlock
    barrier_destroy 'WORKERS_INSTALLED';
    mutex_create 'NODES_ACCEPTED';
    mutex_create 'VELUM_CONFIGURED';
    mutex_create 'UPDATE_FINISHED';
    mutex_create 'CNTRL_FINISHED';

    # Wait for log export from all nodes
    wait_for_children;
}

1;
# vim: set sw=4 et:
