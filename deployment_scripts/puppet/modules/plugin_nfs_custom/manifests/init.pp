#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# == Class: plugin_nfs_custom::install
#
# This class is the main entry point for nfs_custom plugin
# It selects the appropriate class for the deployment mode
#

class plugin_nfs_custom::install() {

  $nfs_packages = [ "nfs-kernel-server", "nfs-common" ]
  $plugin_hash = hiera_hash('fuel-plugin-nfs-custom')
  $export_dir = $plugin_hash[export_dir]

  package { $nfs_packages:
    ensure => "installed"
  }

  file {"$export_dir":
    ensure => directory
  }

  file {"/etc/exports":
    ensure => present,
    content => "$export_dir *(rw,sync,no_subtree_check,no_root_squash)"
  }

  service {"nfs-kernel-server":
    ensure => running
  }

  Package[$nfs_packages] ->
  File["$export_dir"] ->
  File["/etc/exports"] ~>
  Service["nfs-kernel-server"]

}
