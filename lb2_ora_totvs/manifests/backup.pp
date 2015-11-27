class lb2_ora_totvs::backup (
  $datapump_password = $lb2_ora_totvs::params::system_password,
  $bash_file = $lb2_ora_totvs::params::bash_file,
  $user_base_dir = $lb2_ora_totvs::params::user_base_dir,
  $oracle_sid = $lb2_ora_totvs::params::oracle_sid,
  $rman_retention = '1',
  $datapump_retention = '2',
  $datapump_directory = 'DATAPUMP',
  $backup_dir = '/u01/app/oracle/backup',
  $installation_title = $lb2_ora_totvs::params::installation_title,
)
{
  #Diretorio do datapump
  ora_exec {"create directory ${datapump_directory} as '${backup_dir}/datapump'@${oracle_sid}":
    username => 'system',
    password => $datapump_password,
    unless => "select * from dual where 0 = (select decode(directory_name,'${datapump_directory}',0,null) from dba_directories where directory_name='${datapump_directory}')"
  }
  # Evitar password expire
  ora_exec {"alter profile default limit password_life_time unlimited@${oracle_sid}":
     username => 'system',
     password => $datapump_password,
     unless => "select * from dual
     where 0 = (select decode('UNLIMITED',limit,0,null) from dba_profiles where resource_name = 'PASSWORD_LIFE_TIME' and profile='DEFAULT')"
   }
  #Criando a estrutura da pasta de backup
  file { [ "$backup_dir/", "$backup_dir/datapump",
           "$backup_dir/rman", "$backup_dir/log", "$backup_dir/scripts" ]:
               ensure => "directory",
               owner => "oracle",
               group => "oinstall",
               mode => '0750',
  }
  #Criando o script de datapump
  if ! defined(File["${backup_dir}/scripts/datapump.sh"]) {
      file { "${backup_dir}/scripts/datapump.sh":
          ensure  => present,
          content => template("lb2_ora_totvs/datapump_template.sh.erb"),
          mode    => '0775',
          owner   => 'oracle',
          group   => 'oinstall',
          require => File[ "$backup_dir/", "$backup_dir/datapump","$backup_dir/rman", "$backup_dir/log", "$backup_dir/scripts" ],
      }
  }
  #Criando o script de rman
  if ! defined(File["${backup_dir}/scripts/rman.sh"]) {
      file { "${backup_dir}/scripts/rman.sh":
          ensure  => present,
          content => template("lb2_ora_totvs/rman_template.sh.erb"),
          mode    => '0775',
          owner   => 'oracle',
          group   => 'oinstall',
          require => File[ "$backup_dir/", "$backup_dir/datapump","$backup_dir/rman", "$backup_dir/scripts" ],
      }
  }
  #Criando o script de config do rman
  if ! defined(File["${backup_dir}/scripts/rman_config.sh"]) {
        file { "${backup_dir}/scripts/rman_config.sh":
            ensure  => present,
            content => template("lb2_ora_totvs/rman_config_template.sh.erb"),
            mode    => '0755',
            owner   => 'oracle',
            group   => 'oinstall',
            require => File[ "$backup_dir/", "$backup_dir/datapump","$backup_dir/rman", "$backup_dir/scripts" ],
            notify => Exec['rman_config'],
        }
  }
  # Configurando o rman: Padroes LB2
  exec {
    'rman_config':
      command => "${backup_dir}/scripts/rman_config.sh",
      user => 'oracle',
      group => 'oinstall',
      refreshonly => true,
  } 
  cron::job{
    'datapump':
      minute      => '02',
      hour        => '11',
      date        => '*',
      month       => '*',
      weekday     => '*',
      user        => 'oracle',
      command     => "${backup_dir}/scripts/datapump.sh",
  }
  cron::job{
    'rman':
      minute      => '10',
      hour        => '11',
      date        => '*',
      month       => '*',
      weekday     => '*',
      user        => 'oracle',
      command     => "${backup_dir}/scripts/rman.sh -W -s ${oracle_sid} -p ${backup_dir}/log -F 5",
  }
}