$hiera_hash = {
        "datapump" => {
          'command' => "${backup_dir}/scripts/datapump.sh",
          'hour' => '1',
          'user' => 'oracle'
        },
        "rman" => {
          'command' => "${backup_dir}/scripts/rman.sh -W -s ${oracle_sid} -p ${backup_dir}/log -F 5",
          'hour' => '3',
          'user' => 'oracle'
        }
      }
cron::daily{ 'oracle':
  hiera_hash => $hiera_hash
}
