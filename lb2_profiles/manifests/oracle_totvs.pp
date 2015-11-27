class lb2_profiles::oracle_totvs{
  include lb2_ora_totvs
  include lb2_ora_totvs::kernel
  include lb2_ora_totvs::database
  include lb2_ora_totvs::totvs
  include lb2_ora_totvs::backup
  Class['lb2_ora_totvs::kernel'] -> 
    Class['lb2_ora_totvs'] -> 
      Class['lb2_ora_totvs::database'] -> 
        Class['lb2_ora_totvs::totvs'] -> 
          Class['lb2_ora_totvs::backup']
}
