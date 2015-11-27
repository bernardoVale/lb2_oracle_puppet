class lb2_ora_totvs (
  String $version = $lb2_ora_totvs::params::version,
  String $bash_template = 'bash_profile.erb',
  String $bash_file = '.bash_profile',
  String $oracle_home = '/u01/app/oracle/product/11.2.0/db_1',
  String $oracle_base = '/u01/app/oracle',
  String $oracle_sid  = 'totvs',
  String $database_version = 'SEONE',
  String $user_base_dir = '/home',
  String $listener_name = 'listener',
  String $listener_port = '1521',
) inherits lb2_ora_totvs::params {
$puppet_download_mnt_point = "puppet:///modules/lb2_ora_totvs/"
# Configurar bash_profile ou .profile dependendo do SO
  if ! defined(File["${user_base_dir}/oracle/${bash_file}"]) {
      file { "${user_base_dir}/oracle/.bash_profile":
          ensure  => present,
          content => regsubst(template("lb2_ora_totvs/$bash_template"), '\r\n', "\n", 'EMG'),
          mode    => '0775',
          owner   => 'oracle',
          group   => 'oinstall',
      }
    }
  oradb::installdb{ $lb2_ora_totvs::params::install_name:
      version            => $lb2_ora_totvs::params::db_version,
      file               => $lb2_ora_totvs::params::file,
      database_type      => $database_version,
      oracle_base        => $oracle_base,
      oracle_home        => $oracle_home,
      bash_profile       => true,
      user               => 'oracle',
      group              => 'dba',
      group_install      => 'oinstall',
      group_oper         => false,
      download_dir       => $lb2_ora_totvs::params::download_dir,
      zip_extract        => $lb2_ora_totvs::params::zip_extract,
      puppet_download_mnt_point => $puppet_download_mnt_point,
      require => [
        User['oracle'],
        File["${user_base_dir}/oracle/${bash_file}"]],
  } -> 
  if ! defined(File["${oracle_home}/network/admin/listener.ora"]) {
        file { "${oracle_home}/network/admin/listener.ora":
            ensure  => present,
            content => regsubst(template("lb2_ora_totvs/listener.ora.erb"), '\r\n', "\n", 'EMG'),
            mode    => '0640',
            owner   => 'oracle',
            group   => 'oinstall',
        }
  } ->
  db_listener{ 'startlistener':
    ensure          => 'running',  # running|start|abort|stop
    oracle_base_dir => $oracle_base,
    oracle_home_dir => $oracle_home,
    os_user         => 'oracle',
    listener_name   => $listener_name # which is the default and optional
  } ->
  oradb::database{ 'totvsDb_Create':
    oracle_base               => $oracle_base,
    oracle_home               => $oracle_home,
    version                   => $version,
    user                      => 'oracle',
    group                     => 'dba',
    template                  => $lb2_ora_totvs::params::db_template,
    download_dir              => '/u01/app',
    action                    => 'create',
    db_name                   => $oracle_sid,
    db_port                   => $listener_port,
    sys_password              => 'oracle',
    system_password           => 'oracle',
    data_file_destination     => "${oracle_base}/oradata",
    recovery_area_destination => "${oracle_base}/flash_recovery_area",
    character_set             => "WE8MSWIN1252",
    nationalcharacter_set     => "AL16UTF16",
    sample_schema             => 'FALSE',
    memory_percentage         => "40",
    memory_total              => "800",
    database_type             => "MULTIPURPOSE",
    em_configuration          => "NONE",
  } ->
  oradb::tnsnames{'SPEDADV':
      oracle_home          => $oracle_home,
      user                 => 'oracle',
      group                => 'oinstall',
      server               => { myserver => { host => $hostname, port => $listener_port, protocol => 'TCP' }},
      connect_service_name => $oracle_sid,
    }
    oradb::tnsnames{'DADOSADV':
      oracle_home          => $oracle_home,
      user                 => 'oracle',
      group                => 'oinstall',
      server               => { myserver => { host => $hostname, port => $listener_port, protocol => 'TCP' }},
      connect_service_name => $oracle_sid,
    }
    oradb::tnsnames{'LISTENER':
    entry_type         => 'listener',
    oracle_home        => $oracle_home,
    user               => 'oracle',
    group              => 'oinstall',
    server             => { myserver => { host => $hostname, port => $listener_port, protocol => 'TCP' }},
  }
  ora_user{ "totvs@${oracle_sid}":
        temporary_tablespace                  => 'temp',
        default_tablespace                    => 'DATA',
        password                              => 'totvs',
        grants                                => ['DBA', 'UNLIMITED TABLESPACE'],
        quotas                                => {
                                                 "DATA"  => 'unlimited',
                                                },
        require                               => Exec['oracle database totvsDb_Create']
  } ->
  ora_user{ "nfe@${oracle_sid}":
        temporary_tablespace                  => 'temp',
        default_tablespace                    => 'DATA',
        password                              => 'nfe',
        grants                                => ['DBA', 'UNLIMITED TABLESPACE'],
        quotas                                => {
                                                 "DATA"  => 'unlimited',
                                                 },
        require                               => Exec['oracle database totvsDb_Create']
  }
}