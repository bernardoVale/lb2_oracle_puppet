class lb2_profiles::oracle_viasoft{
  include lb2_ora_totvs
  include lb2_ora_totvs::kernel
  include lb2_ora_totvs::backup
  include lb2_ora_totvs::pos_install
  include lb2_ora_totvs::viasoft
  Class['lb2_ora_totvs::kernel'] -> 
    Class['lb2_ora_totvs'] -> 
      class { 'lb2_ora_totvs::database':
        template => 'viasoft11gr2',
      } -> 
          Class['lb2_ora_totvs::backup'] ->
            Class['lb2_ora_totvs::pos_install'] ->
              Class['lb2_ora_totvs::viasoft']
}