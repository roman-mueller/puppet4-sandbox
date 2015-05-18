# About  
This is a playground repository to get more familiar with Puppet 4, future parser, PuppetDB, MCollective and puppetserver 2.  
It is intended to be a quick way to spawn up a fully working Puppet 4 environment.  

In the Vagrantfile there are 2 VMs defined.  
A puppetserver ("puppet") and a puppet node ("node1") both running CentOS 7.0.  
Classes get configured via hiera (see `code/hieradata/*`).  

# Requirements
I'm using Vagrant 1.7.2 and VirtualBox as the provisioner.  
I'm running this on Mac OS X but it should also run on other operating systems, but I haven't tested it.  

The puppetserver VM is configured to use 3GB of RAM.  
The node is using the default (usually 512MB).  

# Usage
After cloning the repository make sure the submodules are also updated:  
```
$ git clone https://github.com/roman-mueller/puppet4-sandbox
$ cd puppet4-sandbox
$ git submodule update --init --recursive
```

Now you can simply run `vagrant up puppet` to get a fully set up puppetserver.  
The `code/` folder will be a synced folder and gets mounted to `/etc/puppetlabs/code` inside the VM.  

If you want to attach a node to the puppetserver simply run `vagrant up node1`.  
Once provisioned you only need to sign the certificate request on the puppetserver.  
For that login to the puppet VM (`vagrant ssh puppet`).  
Then check the queued certificate requests and sign it:  
```
[vagrant@puppet ~]$ sudo /opt/puppetlabs/bin/puppet cert list
  "node1" (SHA256) E3:97:CE:74:78:0E:77:1C:9C:97:AC:77:BC:4B:27:19:9D:7F:6D:B1:7F:18:07:7A:DA:B8:77:D7:2F:15:4D:42
[vagrant@puppet ~]$ sudo /opt/puppetlabs/bin/puppet cert sign node1
Notice: Signed certificate request for node1
Notice: Removing file Puppet::SSL::CertificateRequest node1 at '/etc/puppetlabs/puppet/ssl/ca/requests/node1.pem'
```
After that puppet will run automatically every 30 minutes on the node and apply your changes.  
You can also run it manually:  
```
$ vagrant ssh node1
[vagrant@node1 ~]$ sudo /opt/puppetlabs/bin/puppet agent -t
Info: Caching certificate for node1
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for node1
Info: Retrieving pluginfacts
Info: Retrieving plugin
(...)
Notice: Applied catalog in 0.52 seconds
```

PuppetDB gets installed and started by default.  
The local port 8080 gets forwarded to the Vagrant VM to port 8080.  
So you can access the PuppetDB dashboard via http://127.0.0.1:8080/dashboard/index.html.  
All necessary keys get created when it starts for the first time.  
The puppetserver is configured to store reports in the DB, so you can start playing with that too right away.  

Also MCollective gets installed and configured.  
It should also work out of the box, but the "node1" won't yet register to the environment:  
```
[vagrant@puppet ~]$ /opt/puppetlabs/bin/mco ping
puppet                                   time=44.73 ms


---- ping statistics ----
1 replies max: 44.73 min: 44.73 avg: 44.73 
```

# Problems
Changes made in `code/environments/production/` do not always get picked up by the puppetserver.  
This is a bug which should be resolved in the next version (https://tickets.puppetlabs.com/browse/PUP-4461).  
If you made changes which don't get applied, try restarting the puppetserver: `systemctl restart puppetserver.service`

You cannot use cfacter yet, instead the legacy facter is used.  
That is a bug and will be resolved soon in the next version (https://tickets.puppetlabs.com/browse/FACT-965).  

# Hacks
There are not yet Vagrant boxes available with Puppet 4 pre-installed.
I wrote a shell provisioner ("puppetupgrade.sh") which removes Puppet 3.x from the official puppetlabs Vagrant boxes and installs puppet-agent afterwards.
The advantage of this over me creating a new box is that you can retrace every change I'm making to the trustworthy puppetlabs Vagrant box.

At the time of writing Vagrant (v1.7.2) does not support Puppet 4 yet (https://github.com/mitchellh/vagrant/issues/3740).  
It is always passing a deprecated option to puppet and it cannot be configured to find the binary at the new correct location.  
To work around this I'm using a inline shell provisioner to call puppet from Vagrant.  

There is no DNS server running in the private network.  
All nodes have each other in their `/etc/hosts/` files.  

Starting the puppetserver sometimes hits the systemd timeout (https://tickets.puppetlabs.com/browse/SERVER-557).  
To work around this, the file `/etc/systemd/system/puppetserver.service.d/local.conf` gets created which overrides the timeout and sets it to 500 seconds.
