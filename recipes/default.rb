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

# Configure authentication services.
if node['repose']['client_auth']['databag_name']
  Chef::Log.info node['repose']['client_auth']['databag_name']
  auth_info = data_bag_item(node['repose']['client_auth']['databag_name'], 'repose')
  node.set['repose']['client_auth']['auth_provider'] = auth_info['auth_provider']
  node.set['repose']['client_auth']['username_admin'] = auth_info['username_admin']
  node.set['repose']['client_auth']['password_admin'] = auth_info['password_admin']
  node.set['repose']['client_auth']['tenant_id'] = auth_info['tenant_id']
  node.set['repose']['client_auth']['auth_uri'] = auth_info['auth_uri']
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
