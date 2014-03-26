# repose target
normal['repose']['target_port'] = 9311
normal['repose']['target_protocol'] = 'http'
normal['repose']['target_hostname'] = 'localhost'

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
normal['repose']['client_auth']['filters'] = [
  {
    'uri_regex' => '/',
    'configuration' => 'client-auth-n-version.cfg.xml',
    'auth_provider' =>  'OPENSTACK',
    'username_admin' => 'admin',
    'password_admin' => 'password',
    'tenant_id' => 'tenant-id',
    'auth_uri' => 'https://identity.api.rackspacecloud.com/v2.0',
    'tenanted' => false,
    'mapping_regex' => [],
    'mapping_type' => 'CLOUD',
    'delegable' => false,
    'request_groups' => true,
    'token_cache_timeout' => 600000,
    'group_cache_timeout' => 600000,
    'endpoints_in_header' => false
  },
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
    'mapping_type' => 'CLOUD',
    'delegable' => false,
    'request_groups' => true,
    'token_cache_timeout' => 600000,
    'group_cache_timeout' => 600000,
    'endpoints_in_header' => false
  }
]
