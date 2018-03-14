### Examen 1
**Universidad ICESI**  
**Curso:** Sistemas Distribuidos  
**Nombre:** Carolina Zúñiga Ospina  
**Código:**  A00315292

**Url Repositorio:** 

### Solución a las preguntas

2. 
- Comandos necesarios para el aprovisionamiento de los servidores web:
```
sudo yum install -y httpd
systemctl start  httpd.service
systemctl enable httpd.service
```
Además es necesario crear el archivo **index.html** en el directorio **/var/www/html/index.html**. 

- Comandos necesarios para el aprovisionamiento del balanceador:
el balanceador se implementó utilizando el servicio haproxy.

```
sudo yum install -y haproxy
systemctl start  haproxy.service
systemctl enable haproxy.service
```
Además es necesario editar el archivo de configuración para el proxy que se encargará de balancear la carga llamado **haproxy.cfg**, este archivo está ubicado en el directorio **/etc/haproxy/haproxy.cfg**. Esta es la parte final de dicho archivo, las variables presentes se encuentran definidas en la carpeta de atributos.

```
backend nodes
    balance     roundrobin

     server web1 <%= @ip1 %>:80 check
     server web2 <%= @ip2 %>:80 check

```

3. Archivo Vagrantfile utilizado:

```Ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  config.omnibus.chef_version = :latest
  config.vm.define :centos_server do |server|
    server.vm.box = "centos/7"
    server.vm.network :private_network, ip: "192.168.33.10"
    server.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048","--cpus", "8", "--name", "centos_webserver_1" ]
    end
     config.vm.provision :chef_solo do |chef|
       chef.install = false
       chef.cookbooks_path = "cookbooks"
       chef.add_recipe "httpd"
     end 
  end
  config.vm.define :centos_server2 do |server2|
    server2.vm.box = "centos/7"
    server2.vm.network :private_network, ip: "192.168.33.11"
    server2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048","--cpus", "8", "--name", "centos_webserver_2" ]
    end
     config.vm.provision :chef_solo do |chef|
       chef.install = false
       chef.cookbooks_path = "cookbooks"
       chef.add_recipe "httpd2"
     end 
  end
  config.vm.define :balanceador do |hp|
    hp.vm.box = "centos/7"
    hp.vm.network :private_network, ip: "192.168.33.12"
    hp.vm.network "public_network", bridge: "eth4", ip:"192.168.131.116", netmask: "255.255.255.0"    
    hp.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "balanceador" ]
    end
    hp.vm.provision :chef_solo do |chef|
      chef.install = false
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "haproxy"
    end
  end
end
```

4. cookbooks: Todos los cookbooks empleados para el parcial se encuentran en la ruta /provisioning/cookbooks de este repositorio.

6. Evidencias del funcionamiento del balanceador: En esta imagen se ve que a través de la ip del balanceador se puede acceder a los 2 servidores web distintos cada que se refresca el navegador. 

![][1]

7. problemas encontrados:
El único problema encontrado en el aprovisionamiento de las máquinas fue el siguiente y ocurrió al momento de ejecutar el vagrant up. 

```
[default] Running provisioner: chef_solo...
The chef binary (either `chef-solo` or `chef-client`) was not found on
the VM and is required for chef provisioning. Please verify that chef
is installed and that the binary is available on the PATH.
```
este error se solucionó escribiendo la siguiente línea en el vagrantfile

```
config.omnibus.chef_version = :latest
```
con esta línea se asegura que chef-solo o chef-client esté instalado en las máquinas virtuales. 

### Referencias 
- https://www.digitalocean.com/community/tutorials/an-introduction-to-haproxy-and-load-balancing-concepts

[1]: images/balanceador.gif