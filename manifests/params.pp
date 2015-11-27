class lb2_ora_totvs::params (
   $version = '11.2',
   $ship_software = true,
   $action = 'create',
   $oracle_sid = 'totvs',
   $db_port = '1521',
   $sys_password = 'oracle',
   $system_password = 'oracle',
   $character_set = 'WE8MSWIN1252',
   $nationalcharacter_set = 'AL16UTF16',
   $bash_file = '.bash_profile',
   $user_base_dir = '/home',
   $installation_title = 'totvsDb_Create',
   $listener_port = '1521',
   $ora_binary_folder = '/u01',
   $ora_binary_files = 'app',
){
  if $osfamily == 'Redhat'{
    $bash_file = '.bash_profile'
    if $operatingsystem == 'OracleLinux'{
      $install_list = ['oracle-rdbms-server-11gR2-preinstall', 'oracle-rdbms-server-12cR1-preinstall']
    }else{
      $install_list = [ 'binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64','ksh.x86_64','libaio.x86_64',
             'libgcc.x86_64', 'libstdc++.x86_64', 'make.x86_64','compat-libcap1.x86_64', 'gcc.x86_64',
             'gcc-c++.x86_64','glibc-devel.x86_64','libaio-devel.x86_64','libstdc++-devel.x86_64',
             'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext.x86_64','libXtst.x86_64']
    }
  }elsif $osfamily == 'Suse'{
    $bash_file = '.profile'
    $install_list = ['orarun', 'binutils', 'libstdc++33', 'glibc', 'ksh', 'libaio', 'libgcc', 'libstdc++', 'make', 'libcap1', 'gcc', 'gcc-c++', 'glibc-devel', 'libaio-devel', 'libstdc++-devel', 'sysstat', 'unixODBC-devel', 'glibc-32bit', 'xorg-x11-libXext']
  }

  $oracle_base = '/u01/app/oracle'
  if $version == '12.1'{
    $install_name = '12.1.0.2_Linux-x86-64'
    $db_version = '12.1.0.2'
    $db_template = 'totvs12c'
    $oracle_home = "${oracle_base}/product/12.1.0/db_1"
    if $ship_software{
      $zip_extract = true
      $download_dir = '/u01/app'
      $file = 'p17694377_121020_Linux-x86-64'
    }else {
      $zip_extract = false
      # Verificar para ver se preciso setar os valores default
      if ($ora_binary_folder != '/u01') and ($ora_binary_files != 'app') {
          $download_dir = $ora_binary_folder
          $file = $ora_binary_files
      }
    }
  }elsif $version == '11.2'{
    $install_name = '112040_Linux-x86-64'
    $db_version = '11.2.0.4'
    $db_template = 'totvs11gr2'
    $oracle_home = "${oracle_base}/product/11.2.0/db_1"
    if $ship_software{
      $zip_extract = true
      $download_dir = '/u01/app'
      $file = 'p13390677_112040_Linux-x86-64'
    }else {
      $zip_extract = false
      # Verificar para ver se preciso setar os valores default
      if ($ora_binary_folder != '/u01') and ($ora_binary_files != 'app') {
          $download_dir = $ora_binary_folder
          $file = $ora_binary_files
      }
    }
  }
}
