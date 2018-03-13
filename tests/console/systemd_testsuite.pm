# SUSE's openQA tests
#
# Copyright © 2017 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Run testsuite included in systemd sources
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base "consoletest";
use warnings;
use strict;
use testapi;
use utils;
use version_utils qw(is_leap is_tumbleweed is_sle);

sub run {
    my $qa_head_repo = get_required_var('QA_HEAD_REPO');

    # install systemd testsuite
    select_console 'root-console';
    zypper_call "ar $qa_head_repo systemd-testrepo";
    zypper_call '--gpg-auto-import-keys ref';
    assert_script_run 'systemd --version';                                               # show version
    assert_script_run 'systemd_version=`systemd --version | head -1 | cut -d\  -f2`';    # save version to var
    my $package_name = 'systemd-v$systemd_version-testsuite';
    assert_script_run 'zypper -n se -sx ' . $package_name;
    zypper_call 'in ' . $package_name;
    if (is_leap('16.0+') || is_tumbleweed || is_sle('16+')) {
        # Systemd has split its nspawn feature to a systemd-container package.
        #   - This change is not included in SLE15 nor Leap15.
        record_soft_failure('poo#32614 - Missing systemd-container');
        zypper_call('in systemd-container');
    }

    # run the testsuite test scripts
    assert_script_run 'cd /var/opt/systemd-tests';
    assert_script_run './run-tests.sh --all 2>&1 | tee /tmp/testsuite.log', 1200;
    assert_script_run 'grep "# FAIL:  0" /tmp/testsuite.log';
    assert_script_run 'grep "# ERROR: 0" /tmp/testsuite.log';
}


sub post_fail_hook {
    my ($self) = shift;
    $self->SUPER::post_fail_hook;
    assert_script_run('cd /var/opt/systemd-tests/');
    assert_script_run('cp /tmp/testsuite.log logs/');
    assert_script_run('tar -cjf systemd-testsuite-logs.tar.bz2 logs/');
    upload_logs('systemd-testsuite-logs.tar.bz2');
}


1;
