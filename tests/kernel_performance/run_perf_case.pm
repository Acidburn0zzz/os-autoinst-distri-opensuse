# SUSE's openQA tests
#
# Copyright © 2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
#
# Summary: run performance cases
# Maintainer: Joyce Na <jna@suse.de>

package run_perf_case;
use strict;
use power_action_utils 'power_action';
use warnings;
use testapi;
use base "y2logsstep";

sub run_one_by_one {
    my $case     = get_var("CASE_NAME");
    my $time_out = get_var("RUN_TIME_MINUTES");

    # create run list
    assert_script_run("echo \'#!/bin/bash\' > /root/qaset/list");
    assert_script_run("echo \'SQ_TEST_RUN_LIST=(\' >> /root/qaset/list");

    # if customized monitor defined,add it to runlist,otherwise use default one
    if (get_var("MONITOR")) {
        my $monitor = get_var("MONITOR");
        assert_script_run("echo \"$monitor\" >>/root/qaset/list");
    }
    assert_script_run("echo \"$case\" >> /root/qaset/list");
    assert_script_run("echo \')\' >> /root/qaset/list");
    assert_script_run("/usr/share/qa/qaset/qaset reset");
    assert_script_run("/usr/share/qa/qaset/run/performance-run.upload_Beijing");
    while (1) {

        #wait for case running completd with /var/log/qaset/control/DONE
        if (script_run("ls /var/log/qaset/control/ | grep DONE") == "DONE") {
            last;
        }
        if ($time_out == 0) {
            die "Test run didn't finish within time limit";
        }
        sleep 60;
        diag "Test is not finished yet, sleeping with $time_out minutes remaining";
        --$time_out;
    }
}

sub run {
    run_one_by_one;
    power_action('poweroff');
}

sub test_flags {
    return {fatal => 1};
}

1;

