class lb2_ora_totvs::pos_install(
	$oracle_sid = $lb2_ora_totvs::params::oracle_sid,
	$system_password = $lb2_ora_totvs::params::system_password,
	) inherits lb2_ora_totvs::params {
  # Use this class to for pos installation tasks

  # Evitar password expire
  ora_exec {"alter profile default limit password_life_time unlimited@${oracle_sid}":
     username => 'system',
     password => $system_password,
     unless => "select * from dual
     where 0 = (select decode('UNLIMITED',limit,0,null) from dba_profiles where resource_name = 'PASSWORD_LIFE_TIME' and profile='DEFAULT')"
   }
}