
package %w(vim dstat mc nmap sysstat rsync apt-utils snmpd nagios-nrpe-server libsys-statistics-linux-perl ntpdate htop nload logwatch vsftpd db-util watchdog chkrootkit rkhunter unhide nagios-plugins-basic nagios-plugins-common nagios-plugins-standard)


bash "remove_defaults" do
  code <<-EOH
    mv /etc/nagios/nrpe.cfg /etc/nagios/nrpe-orig
    mv /etc/snmp/snmpd.conf /etc/snmp/snmpd-orig
  EOH
  not_if { ::File.exists?("/etc/snmp/snmpd-orig") }
end

cookbook_file "/etc/snmp/snmpd.conf" do
  source "default/snmpd.conf"
  not_if { ::File.exists?("/etc/snmp/snmpd.conf") }
end

cookbook_file "/etc/nagios/nrpe.cfg" do
  source "default/nrpe.cfg"
  not_if { ::File.exists?("/etc/nagios/nrpe.cfg") }
end

cookbook_file "/usr/lib/nagios/plugins/check_linux_stats.pl" do
  source "default/check_linux_stats.pl"
  not_if { ::File.exists?("/usr/lib/nagios/plugins/check_linux_stats.pl") }
end

cookbook_file "/usr/lib/nagios/plugins/check_mem.pl" do
  source "default/check_mem.pl"
  not_if { ::File.exists?("/usr/lib/nagios/plugins/check_mem.pl") }
end

cookbook_file "/usr/lib/nagios/plugins/check_diskio.sh" do
  source "default/check_diskio.sh"
  not_if { ::File.exists?("/usr/lib/nagios/plugins/check_diskio.sh") }
end

service "snmpd" do
  action [:enable, :start]
end

service "nagios-nrpe-server" do
  action [:enable, :start]
end

cron "chef-client-run" do
  action :create
  minute '30'
  user 'root'
  command "chef-client"
end
