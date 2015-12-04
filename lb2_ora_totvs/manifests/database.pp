class lb2_ora_totvs::database(
    $installation_title = $lb2_ora_totvs::params::installation_title,
    $oracle_base = $lb2_ora_totvs::params::oracle_base,
    $oracle_home = $lb2_ora_totvs::params::oracle_home,
    $version = $lb2_ora_totvs::params::version,
    $template = $lb2_ora_totvs::params::db_template,
    $action = $lb2_ora_totvs::params::action,
    $oracle_sid = $lb2_ora_totvs::params::oracle_sid,
    $db_port = $lb2_ora_totvs::params::db_port,
    $sys_password = $lb2_ora_totvs::params::sys_password,
    $system_password = $lb2_ora_totvs::params::system_password,
    $character_set = $lb2_ora_totvs::params::character_set,
    $nationalcharacter_set = $lb2_ora_totvs::params::nationalcharacter_set,
    $download_dir = $lb2_ora_totvs::params::download_dir,
    $data_file_destination = $lb2_ora_totvs::params::data_file_destination,
    $recovery_area_destination = $lb2_ora_totvs::params::recovery_area_destination,
    ) inherits lb2_ora_totvs::params  {
    if File["${oracle_home}/bin/dbca"] {
        oradb::database{ $installation_title:
            oracle_base               => $oracle_base,
            oracle_home               => $oracle_home,
            version                   => $version,
            user                      => 'oracle',
            group                     => 'dba',
            template                  => $template,
            download_dir              => $download_dir,
            action                    => $action,
            db_name                   => $oracle_sid,
            db_port                   => $listener_port,
            sys_password              => $sys_password,
            system_password           => $system_password,
            data_file_destination     => $data_file_destination,
            recovery_area_destination => $recovery_area_destination,
            character_set             => $character_set,
            nationalcharacter_set     => $nationalcharacter_set,
            sample_schema             => 'FALSE',
            memory_percentage         => "40",
            memory_total              => "800",
            database_type             => "MULTIPURPOSE",
            em_configuration          => "NONE",
        }
      }else{
         fail("Couldn't find dbca on given Oracle_home:${oracle_home}")
        }
}
