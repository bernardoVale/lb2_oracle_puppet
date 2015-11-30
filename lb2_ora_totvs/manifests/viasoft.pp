class lb2_ora_totvs::viasoft(
	$backup_dir = $lb2_ora_totvs::params::backup_dir,
	$datapump_directory = $lb2_ora_totvs::params::datapump_directory,
	$system_password = $lb2_ora_totvs::params::system_password,
	$oracle_sid = $lb2_ora_totvs::params::oracle_sid,
	$oracle_home = $lb2_ora_totvs::params::oracle_home,
	$dumpfile = 'viasoft.dmp',
){
	file { $dumpfile:
		path => "${backup_dir}/datapump/${dumpfile}",
		ensure => file,
		source => "file:///vagrant/oracle//${dumpfile}",
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
	}
	# ora_exec {"@${oracle_sid}":
 #     username => 'system',
 #     password => $system_password,
 #     unless => "select * from dual
 #     where 0 = (select decode('UNLIMITED',limit,0,null) from dba_profiles where resource_name = 'PASSWORD_LIFE_TIME' and profile='DEFAULT')"
 #     require => Exec['impdp_viasoft'],
 #   }
	# exec { 'name':
	# 	command      => '/bin/echo',
	# 	#path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
	# 	#refreshonly => true,

	# }
}