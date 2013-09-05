#
# Cookbook Name:: zookeeper
# Recipe:: cleanup
#
# Zookeeper doesn't do any cleanup of snapshots and logs
# so install a cron to keep only the most recent three
#

version = node[:zookeeper][:version]
zk_path = "#{node[:zookeeper][:install_dir]}/zookeeper-#{version}"

log4j       = 'lib/log4j-1.2.15.jar'
slf4j_api   = 'lib/slf4j-api-1.6.1.jar'
slf4j_log4j = 'lib/slf4j-log4j12-1.6.1.jar'

jars = "zookeeper-#{version}.jar:#{log4j}:#{slf4j_api}:#{slf4j_log4j}:conf"

cmd = %Q{
  cd #{zk_path} &&
    java -cp #{jars}
      org.apache.zookeeper.server.PurgeTxnLog
      #{node[:exhibitor][:transaction_dir]}
      #{node[:exhibitor][:snapshot_dir]}
      -n 3
}.delete("\n")

cron 'zookeeper-log-flush' do
  hour '1'
  action :create
  user 'zookeeper'
  command cmd
end
