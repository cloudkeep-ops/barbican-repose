#
# Cookbook Name:: barbican-repose
# Recipe:: default
#
# Copyright (C) 2013 Rackspace, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Note that the yum repository configuration used here was found at this site:
#   http://docs.opscode.com/resource_cookbook_file.html
#

# Find the Repose target endpoint (typically a load balancer).

auth_filters = [
  {
    'uri_regex' => '/.+',
    'configuration' => 'client-auth-n.cfg.xml',
    'auth_provider' =>  'OPENSTACK',
    'username_admin' => 'admin',
    'password_admin' => 'password',
    'tenant_id' => 'tenant-id',
    'auth_uri' => 'https://identity.api.rackspacecloud.com/v2.0',
    'tenanted' => true,
    'mapping_regex' => ['.*/v1/([-|\w]+)/?.*'],
    'version_regex' => ['/'],
    'mapping_type' => 'CLOUD',
    'delegable' => false,
    'request_groups' => true,
    'token_cache_timeout' => 600000,
    'group_cache_timeout' => 600000,
    'endpoints_in_header' => false
  }
]
# Configure authentication services.
if node['repose']['client_auth']['databag_name']
  Chef::Log.info node['repose']['client_auth']['databag_name']
  auth_info = data_bag_item(node['repose']['client_auth']['databag_name'], 'repose')
  auth_filters.each do |auth_filter|
    auth_filter['auth_provider'] = auth_info['auth_provider']
    auth_filter['username_admin'] = auth_info['username_admin']
    auth_filter['password_admin'] = auth_info['password_admin']
    auth_filter['tenant_id'] = auth_info['tenant_id']
    auth_filter['auth_uri'] = auth_info['auth_uri']
  end
  node.set['repose']['client_auth']['filters'] = auth_filters
end

include_recipe "repose"

#TODO(jwood) Must do this until we fix chunking issue with uWSGI.
cookbook_file "/etc/repose/http-connection-pool.cfg.xml" do
  source "http-connection-pool.cfg.xml"
  owner node['repose']['owner']
  group node['repose']['group']
  mode '0644'
  notifies :restart, 'service[repose-valve]'
end
