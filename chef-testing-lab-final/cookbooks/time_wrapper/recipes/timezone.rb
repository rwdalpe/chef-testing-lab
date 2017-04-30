node.override['tz'] = node['wrapper']['time']['tz']
node.override['timezone']['use_symlink'] = true

include_recipe 'timezone-ii::default'

template '/etc/sysconfig/clock' do
    source 'etc-sysconfig-clock.erb'
    owner 'root'
    group 'root'
    mode '0644'
end