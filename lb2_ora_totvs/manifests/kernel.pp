class lb2_ora_totvs::kernel (
  $install_list = lb2_ora_totvs::params::install_list,
  $shm_size = '4000m'
)
{
  #Install_list esta definido no Hiera para SLES ou RedHat
  if $install_list == undef{
    fail("OS not supported for pre-install automation")
  }else {
    #Configurar /etc/hosts
    $my_hash = {
       "$fqdn" => {
          'ip' => "$ipaddress",
          'host_aliases' => "$hostname"
        }
    }
    class { 'hosts':
      host_entries => $my_hash
    }
    # disable the firewall
    service { iptables:
      enable    => false,
      ensure    => false,
      hasstatus => true,
    }
    mount { '/dev/shm':
      ensure      => present,
      atboot      => true,
      device      => 'tmpfs',
      fstype      => 'tmpfs',
      options     => "size=$shm_size", 
    }  
    $all_groups = ['oinstall','dba']
    group { $all_groups :
      ensure      => present,
    }
    user { 'oracle' :
      ensure      => present,
      uid         => 54321,
      gid         => 'oinstall',
      groups      => ['oinstall','dba'],
      shell       => '/bin/bash',
      password    => pw_hash('oracle', 'SHA-512','mysalt'),
      home        => "/home/oracle",
      comment     => "Oracle Database User",
      require     => Group[$all_groups],
      managehome  => true,
    }
    class { 'limits':
      config => {
                 '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                 'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                                 'nproc'  => { soft => '2048'   , hard => '16384',  },
                                 'stack'  => { soft => '10240'  ,},},
                 },
      use_hiera => false,
    }
    package { $install_list:
      ensure => present,
      require => User['oracle'],
    }
  }
}
