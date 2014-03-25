# repose target
default['repose']['target_port'] = 9311
default['repose']['target_protocol'] = 'http'
default['repose']['target_hostname'] = 'localhost'

# repose listening ports
normal['repose']['port'] = 8080
normal['repose']['ssl_port'] = 8443
# repose filters
normal['repose']['filters'] = ['http-logging', 'content-normalization', 'ip-identity', 'client-auth', 'api-validator']

#TODO(dmend): This should probably be done in the recipe.  I'm seeing weird 
# node object merging issues with this here. :-\
normal['repose']['endpoints'] = [
  { 'id' => 'barbican_api',
    'protocol' => node['repose']['target_protocol'],
    'hostname' => node['repose']['target_hostname'],
    'port' => node['repose']['target_port'],
    'root_path' => '/',
    'default' => true,
  }
]

# Configure repose clustering
normal['repose']['cluster_id'] = node.environment || '_default'
normal['repose']['node_id'] = node['hostname']
normal['repose']['peer_search_role'] = 'barbican-repose'

#configure client auth
normal['repose']['client_auth']['databag_name'] = nil
normal['repose']['client_auth']['delegable'] = false
normal['repose']['client_auth']['tenanted'] = false
normal['repose']['client_auth']['request_groups'] = false
normal['repose']['client_auth']['auth_provider'] = 'OPENSTACK'
normal['repose']['client_auth']['tenant_id'] = ''
normal['repose']['client_auth']['auth_uri'] = 'https://identity.api.rackspacecloud.com/v2.0/'
default['repose']['client_auth']['mapping_regex'] = ['.*/v1/([-|\w]+)/?.*']
normal['repose']['client_auth']['delegable'] = false
normal['repose']['client_auth']['tenanted'] = true
normal['repose']['client_auth']['request_groups'] = false
