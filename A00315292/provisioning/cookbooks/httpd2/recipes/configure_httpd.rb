service "httpd" do
  action [:enable, :start]
end

cookbook_file '/var/www/html/index.html' do
  source 'index.html'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end

