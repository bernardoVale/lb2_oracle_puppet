#!/bin/bash
#Installing and configuring LB2 Oracle TOTVS on Oracle Linux 6

#Installing repo
wget https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
rpm -ivh puppetlabs-release-el-6.noarch.rpm

#Installing puppet
yum install -y puppet-3.8.4-1.el6
cd /etc/puppet/modules

#Getting LB2 ORA TOTVS
wget https://github.com/bernardoVale/lb2_oracle_puppet/archive/master.zip
unzip master.zip
mv lb2_oracle_puppet-master/* .
rm -rf lb2_oracle_puppet-master/

#Configuring Hiera
mkdir -p /etc/puppet/hieradata/nodes
HOSTNAME=`facter hostname`
touch /etc/puppet/hieradata/nodes/$HOSTNAME.yaml
mv common.yaml /etc/puppet/hieradata/
mv hiera.yaml /etc/puppet/

#Getting dependecies
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-concat
puppet module install hajee-easy_type
puppet module install ghoneycutt-hosts
puppet module install erwbgy-limits
puppet module install hajee-oracle
puppet module install biemond-oradb


# Moving templates
cp /etc/puppet/modules/lb2_ora_totvs/templates/totvs1* /etc/puppet/modules/oradb/templates/
cp /etc/puppet/modules/lb2_ora_totvs/templates/viasoft* /etc/puppet/modules/oradb/templates/

#Now just customize inside $HOSTNAME.yaml and apply your code 
#Applying code
#puppet apply -e "include lb2_profiles::oracle_totvs"