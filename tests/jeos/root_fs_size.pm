# SUSE's openQA tests
#
# Copyright © 2017 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Check root filesystem size
# Maintainer: Michal Nowak <mnowak@suse.com>

use base 'opensusebasetest';
use strict;
use testapi;

sub run {
    my $expected_size = check_var('VIRSH_VMM_FAMILY', 'hyperv') ? 30 : 24;
    assert_script_run "df --output=size --block-size=G / | sed 1d | tr -d ' ' | grep ^${expected_size}G\$";
}

1;
