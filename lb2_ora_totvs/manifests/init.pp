class lb2_ora_totvs (
  $version = $lb2_ora_totvs::params::version,
  $bash_file = $lb2_ora_totvs::params::bash_file,
  $oracle_home = $lb2_ora_totvs::params::oracle_home,
  $oracle_base = $lb2_ora_totvs::params::oracle_base,
  $oracle_sid  = $lb2_ora_totvs::params::oracle_sid,
  $user_base_dir = $lb2_ora_totvs::params::user_base_dir,
  $bash_template = 'bash_profile.erb',
  $database_version = 'SEONE',
  $listener_name = 'listener',
  $listener_port = $lb2_ora_totvs::params::listener_port,
  $installation_title = $lb2_ora_totvs::params::installation_title
) inherits lb2_ora_totvs::params {
  $puppet_download_mnt_point = "puppet:///modules/lb2_ora_totvs"
  
  # Configurar bash_profile ou .profile dependendo do SO
  if ! defined(File["${user_base_dir}/oracle/${bash_file}"]) {
      file { "${user_base_dir}/oracle/${bash_file}":
          ensure  => present,
          content => regsubst(template("lb2_ora_totvs/$bash_template"), '\r\n', "\n", 'EMG'),
          mode    => '0775',
          owner   => 'oracle',
          group   => 'oinstall',
      }
  }
  oradb::installdb{ $installation_title:
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
  #if ! defined(File["${oracle_home}/network/admin/listener.ora"]) {
        file { "${oracle_home}/network/admin/listener.ora":
            ensure  => present,
            content => regsubst(template("lb2_ora_totvs/listener.ora.erb"), '\r\n', "\n", 'EMG'),
            mode    => '0640',
            owner   => 'oracle',
            group   => 'oinstall',
        } ->
  #} ->
  db_listener{ 'startlistener':
    ensure          => 'running',  # running|start|abort|stop
    oracle_base_dir => $oracle_base,
    oracle_home_dir => $oracle_home,
    os_user         => 'oracle',
    listener_name   => $listener_name # which is the default and optional
  }
}