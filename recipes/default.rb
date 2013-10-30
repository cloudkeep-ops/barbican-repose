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

# Build a map of host name to IP addresses, for queue nodes in my cluster.
api_host = "localhost"
if Chef::Config[:solo]
  api_host = node[:solo_api_host]
else
  q_nodes = search(:node, "role:barbican-api AND chef_environment:#{node.chef_environment}")
  if q_nodes.empty?
     Chef::Log.info 'No api nodes found to synchronize with.'
  else
     my_id = node[:hostname].split('-')[1]
     for q_node in q_nodes
       host_id = q_node[:hostname].split('-')[1]
       if my_id == host_id
         api_host = q_node[:ipaddress]
         break
       end
    end
  end
end
Chef::Log.debug "Final host ID: #{api_host}"

# Configure Repose:
node.set['repose']['endpoints'] = [
  { 'id' => 'barbican_api',
    'protocol' => node[:repose][:endpoint_protocol],
    'hostname' => api_host,
    'port' => node[:repose][:endpoint_port],
    'root_path' => '/',
    'default' => true,
  }
]
unless Chef::Config[:solo]
  node.save
end

include_recipe "repose::filter-http-logging"
include_recipe "repose::filter-ip-identity"
include_recipe "repose::service-dist-datastore"
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
