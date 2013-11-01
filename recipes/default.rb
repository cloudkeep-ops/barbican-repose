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

# Do anything needed beyond the standard Repose install here

include_recipe "barbican::_base"

# Find the Repose target endpoint (typically a load balancer).
api_host = "localhost"
if Chef::Config[:solo]
  api_host = node[:solo_api_host]
else
  api_host = node[:repose][:target_hostname]
end
Chef::Log.debug "Final host ID: #{api_host}"

# Configure Repose:
node.set['repose']['endpoints'] = [
  { 'id' => 'barbican_api',
    'protocol' => node[:repose][:target_protocol],
    'hostname' => api_host,
    'port' => node[:repose][:target_port],
    'root_path' => '/',
    'default' => true,
  }
]
unless Chef::Config[:solo]
  node.save
end

# Configure authentication services.
unless Chef::Config[:solo]
  auth_info = data_bag_item(node.chef_environment, :auth)
  node.set[:repose][:client_auth][:auth_provider] = auth_info[:auth_provider]
  node.set[:repose][:client_auth][:username_admin] = auth_info[:username_admin]
  node.set[:repose][:client_auth][:password_admin] = auth_info[:password_admin]
  node.set[:repose][:client_auth][:tenant_id] = auth_info[:tenant_id]
  node.set[:repose][:client_auth][:auth_uri] = auth_info[:auth_uri]
  node.save
end

include_recipe "repose::filter-http-logging"
include_recipe "repose::filter-ip-identity"
include_recipe "repose::filter-client-auth"
include_recipe "repose"

#TODO(jwood) Must do this until we fix chunking issue with uWSGI.
cookbook_file "/etc/repose/http-connection-pool.cfg.xml" do
  source "http-connection-pool.cfg.xml"
  owner node['repose']['owner']
  group node['repose']['group']
  mode '0644'
  notifies :restart, 'service[repose-valve]'
end

# Perform final configuration on the server.
include_recipe 'barbican::_final'
