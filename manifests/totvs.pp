class lb2_ora_totvs::totvs(
 $listener_port = $lb2_ora_totvs::params::listener_port,
 $oracle_home = $lb2_ora_totvs::params::oracle_home,
 $oracle_sid = $lb2_ora_totvs::params::oracle_sid, 
) inherits lb2_ora_totvs::params{
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
                                                    }
        }
        ora_user{ "nfe@${oracle_sid}":
            temporary_tablespace                  => 'temp',
            default_tablespace                    => 'DATA',
            password                              => 'nfe',
            grants                                => ['DBA', 'UNLIMITED TABLESPACE'],
            quotas                                => {
                                                     "DATA"  => 'unlimited',
                                                     },
        }  
}
