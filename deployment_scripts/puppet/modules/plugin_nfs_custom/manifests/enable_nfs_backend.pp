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

class plugin_nfs_custom::enable_nfs_backend() {

  $plugin_hash = hiera_hash('fuel-plugin-nfs-custom')
  $export_dir = $plugin_hash[export_dir]
  $shares_config="/etc/cinder/nfs_shares"
  $packages = [ "nfs-common", "cinder-volume" ]
  $ip = values(get_node_to_ipaddr_map_by_network_role(get_nodes_hash_by_roles(hiera_hash('network_metadata'), ['fuel-plugin-nfs-custom']), 'storage'))

  package { $packages:
    ensure => "installed"
  }

  cinder_config {
    'DEFAULT/volume_driver': value => 'cinder.volume.drivers.nfs.NfsDriver';
    'DEFAULT/nfs_shares_config': value => "$shares_config";
  }

  file {"$shares_config":
     ensure => present,
     content => "${ip}:${export_dir}"
  }

  service {"cinder-volume":
     ensure => running
  }

  Package[$packages] ->
  Cinder_config <||> ->
  File["$shares_config"] ~>
  Service['cinder-volume']

}
