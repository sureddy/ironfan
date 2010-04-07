directory "/usr/local/src" do
  mode      '0775'
  owner     'root'
  group     'admin'
  action    :create
  recursive true
end

cassandra_install_pkg = File.basename(node[:cassandra][:install_url])
cassandra_install_dir = cassandra_install_pkg.gsub(%r{-(?:bin|src)\.tar\.gz}, '')
Chef::Log.info [cassandra_install_pkg, cassandra_install_dir].inspect

remote_file "/usr/local/src/"+cassandra_install_pkg do
  source    node[:cassandra][:install_url]
  mode      "0644"
end

bash 'install from tarball' do
  user         'root'
  cwd          '/usr/local/share'
  code <<EOF
  tar xzf /usr/local/src/#{cassandra_install_pkg}
  true
EOF
  not_if{  File.directory?("/usr/local/share/"+cassandra_install_dir) }
end

link "/usr/local/share/cassandra" do
  to "/usr/local/share/"+cassandra_install_dir
  action :create
end

link "/usr/sbin/cassandra" do
  to "/usr/local/share/cassandra/bin/cassandra"
  action :create
end

# # desc "Regenerate thrift bindings for Cassandra" # Dev only
# task :thrift do
#   puts "Generating Thrift bindings"
#   system(
#     "cd vendor &&
#     rm -rf gen-rb &&
#     thrift -gen rb #{CASSANDRA_HOME}/server/interface/cassandra.thrift")
# end