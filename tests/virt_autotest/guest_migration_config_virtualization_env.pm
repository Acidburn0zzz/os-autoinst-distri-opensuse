# SUSE's openQA tests
#
# Copyright © 2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
# Summary: virt_autotest: Virtualization multi-machine job : Guest Migration
# Maintainer: jerry <jtang@suse.com>

use base virt_autotest_base;
use strict;
use testapi;
use guest_migration_base;

sub run() {
    my ($self) = @_;

    #Turn off the firewall
    $self->execute_script_run("SuSEfirewall2 off", 500);

    #Create disk backup directory
    $self->execute_script_run("[ -d /tmp/pesudo_mount_server ] || mkdir -p /tmp/pesudo_mount_server", 500);

    #Change the config file for hyper_visor
    if ($hyper_visor =~ /xen/) {
        $self->execute_script_run("source /usr/share/qa/virtautolib/lib/virtlib;changeXendConfig", 500);
    }
    else {
        $self->execute_script_run("source /usr/share/qa/virtautolib/lib/virtlib;changeLibvirtConfig", 500);
    }

    #Query and save the ip addres
    my $ip_out = $self->execute_script_run('ip route show|grep kernel|cut -d" " -f12|head -1', 3);
    my $name_out = $self->execute_script_run('hostname', 3);

    set_var('MY_IP',   $ip_out);
    set_var('MY_NAME', $name_out);
    bmwqemu::save_vars();
}
1;
