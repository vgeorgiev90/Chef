
file "/etc/motd" do
  content "IP Address: #{node['ipaddress']}
Catch Phrase: #{node['message']}
"
end
