class lb2_ora_totvs::viasoft(
  $backup_dir = $lb2_ora_totvs::params::backup_dir,
  $datapump_directory = $lb2_ora_totvs::params::datapump_directory,
  $system_password = $lb2_ora_totvs::params::system_password,
  $sys_password = $lb2_ora_totvs::params::sys_password,
  $oracle_sid = $lb2_ora_totvs::params::oracle_sid,
  $oracle_home = $lb2_ora_totvs::params::oracle_home,
  $dumpfile = 'viasoft.dmp',
){
  file { $dumpfile:
    path => "${backup_dir}/datapump/${dumpfile}",
    ensure => file,
    source => "puppet:///modules/lb2_ora_totvs/${dumpfile}",
  }
exec { 'impdp_viasoft':
    command      => "${oracle_home}/bin/impdp system/${system_password}@${oracle_sid} directory=${datapump_directory} dumpfile=${dumpfile} logfile=import_viasoft_base.log schemas=VIASOFTLOGISTICA,VIASOFTGP,VIASOFTMCP,VIASOFTFIN,VIASOFTRH,VIASOFTMERC,VIASOFT,VIASOFTBASE,VIASOFTCP,VIASOFTSYS,VIASOFTFISCAL,VIASOFTCTB",
    require => File[$dumpfile],
    creates => "$backup_dir/datapump/import_viasoft_base.log",
    user => 'oracle',
    group => 'oinstall',
    path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:${oracle_home}/bin',
    environment => ["ORACLE_HOME=${oracle_home}"],
    timeout => 0,
    returns => [0, 5],
  }
  file { "${backup_dir}/scripts/viasoft_grants_script.sql":
    ensure => file,
        content => template("lb2_ora_totvs/viasoft_pos.sql.erb"),
        mode    => '0755',
        owner   => 'oracle',
        group   => 'oinstall',
        notify => Exec['viasoft_grants'],
  }
  exec { 'viasoft_grants':
    command      => "${oracle_home}/bin/sqlplus -S /nolog @${backup_dir}/scripts/viasoft_grants_script.sql",
    environment => ["ORACLE_HOME=${oracle_home}",
      "ORACLE_SID=${oracle_sid}"],
    user => 'oracle',
    group => 'oinstall',
    path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:${oracle_home}/bin',
    require => File["${backup_dir}/scripts/viasoft_grants_script.sql"],
    unless => "test `cat ${backup_dir}/log/viasoft_pos_result.csv | head -c1` = X",
  }
}