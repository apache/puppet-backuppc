# == Class: backuppc::client
#
# Configures a host for backup with the backuppc server.
# Uses storedconfigs to provide the backuppc server with
# required information.
#
# === Parameters
#
# For parameters that are not documented here see the server
# manifest.
#
# [*ensure*]
# Present or absent.
#
# [*client_name_alias*]
# Override the client's host name. This allows multiple clients to all refer to the same physical host. This should only be set in the per-PC config file and is only used by BackupPC at the last moment prior to generating the command used to backup that machine (ie: the value of $Conf{ClientNameAlias} is invisible everywhere else in BackupPC). The setting can be a host name or IP address, eg:
#         $Conf{ClientNameAlias} = 'realHostName';
#         $Conf{ClientNameAlias} = '192.1.1.15';
# will cause the relevant smb/tar/rsync backup/restore commands to be directed to realHostName, not the client name.
# Note: this setting doesn't work for hosts with DHCP set to 1.
#
# [*system_account*]
# Name of the user that will be created to allow backuppc
# access to the system via ssh. This only applies to xfer
# methods that require it. To override this set the system_account
# to an empty string and configure access to the client yourself as
# the default in the global config file (root) or change the
# rsync_client_cmd or tar_client_cmd to suit your setup.
#
# [*system_home_directory*]
# Absolute path to the home directory of the system account.
#
# [*system_additional_commands*]
# Additional sudo commands to whitelist for the system_account. This
# is useful if you need to execute any pre dump *scripts* on client before
# backup. Please prefer system_additional_commands_noexec if you want
# to whitelist a single command/binary since commands specified here
# are going to be allowed without the NOEXEC options. See man sudoers
# for details.
#
# [*system_additional_commands_noexec*]
# Additional sudo commands to whitelist for the system_account. This
# is useful if you need to execute any pre dump commands on client before
# backup.
#
# [*manage_sudo*]
# Boolean. Set to true to configure and install sudo and the
# sudoers.d directory. Defaults to false and is only applied
# if 1) xfer_method requires ssh access and 2) you're using
# the system_account parameter.
#
# [*manage_rsync*]
# Boolean. By default will install the rsync package. If you
# manage this elsewhere set it to false. Defaults to true and
# is only applied if 1) the xfer_method is rsync and 2) you're
# using the system_account parameter.
#
# [*blackout_bad_ping_limit*]
# To allow for periodic rebooting of a PC or other brief periods when a
# PC is not on the network, a number of consecutive bad pings is allowed
# before the good ping count is reset.
#
# [*blackout_periods*]
#  One or more blackout periods can be specified. If a client is subject to blackout then no regular (non-manual) backups will be started during any of these periods. hourBegin and hourEnd specify hours fro midnight and weekDays is a list of days of the week where 0 is Sunday, 1 is Monday etc.
#  For example:
#     $Conf{BlackoutPeriods} = [
#          {
#              hourBegin =>  7.0,
#              hourEnd   => 19.5,
#              weekDays  => [1, 2, 3, 4, 5],
#          },
#     ];
#  specifies one blackout period from 7:00am to 7:30pm local time on Mon-Fri.
#
# [*ping_max_msec*]
# Maximum latency between backuppc server and client to schedule
# a backup. Default to 20ms.
#
# [*ping_cmd*]
# Ping command. The following variables are substituted at run-time:
#      $pingPath      path to ping ($Conf{PingPath})
#      $host          host name
#    Wade Brown reports that on solaris 2.6 and 2.7 ping -s returns the wrong exit status (0 even on failure). Replace with "ping $host 1", which gets the correct exit status but we don't get the round-trip time.
#    Note: all Cmds are executed directly without a shell, so the prog name needs to be a full path and you can't include shell syntax like redirection and pipes; put that in a script if you need it.
#
# [*backups_disable*]
# Disable all full and incremental backups. These settings are useful for a client that
# is no longer being backed up (eg: a retired machine), but you wish to keep the last backups
# available for browsing or restoring to other machines.
#
# [*xfer_method*]
# What transport method to use to backup each host. Valid values are rsync,
# rsyncd, tar and smb.
#
# [*xfer_loglevel*]
# Level of verbosity in Xfer log files. 0 means be quiet, 1 will give will
# give one line per file, 2 will also show skipped files on incrementals,
# higher values give more output.
#
# [*smb_share_name*]
# Name of the host share that is backed up when using SMB. This can be a string or an
# array of strings if there are multiple shares per host.
#
# [*smb_share_username*]
# Smbclient share user name. This is passed to smbclient's -U argument.
#
# [*smb_share_passwd*]
# Smbclient share password. This is passed to smbclient via its PASSWD environment variable.
#
# [*smb_client_full_cmd*]
# Command to run smbclient for a full dump.
#
# [*smb_client_incr_cmd*]
# Command to run smbclient for an incremental dump.
#
# [*smb_client_restore_cmd*]
# Command to run smbclient for a restore.
#
# [*tar_share_name*]
# Which host directories to backup when using tar transport. This can be a string or an array
# of strings if there are multiple directories to backup per host.
#
# [*tar_client_cmd*]
# Command to run tar on the client. GNU tar is required. The default will run
# the tar command as the user you specify in system_account.
#
# [*tar_full_args*]
# Extra tar arguments for full backups.
#
# [*tar_incr_args*]
# Extra tar arguments for incr backups.
#
# [*tar_client_restore_cmd*]
# Full command to run tar for restore on the client. GNU tar is required.
#
# [*rsync_client_cmd*]
# Full command to run rsync on the client machine. The default will run
# the rsync command as the user you specify in system_account.
#
# [*rsync_client_restore_cmd*]
# Full command to run rsync for restore on the client.
#
# [*rsync_share_name*]
# Share name to backup. For $Conf{XferMethod} = "rsync" this should be a
# file system path, eg '/' or '/home'.
#
# [*rsyncd_client_port*]
# Rsync daemon port on host.
#
# [*rsyncd_user_name*]
# Rsync daemon user name on host.
#
# [*rsyncd_passwd*]
# Rsync daemon password on host.
#
# [*rsyncd_auth_required*]
# Whether authentication is mandatory when connecting to the client's rsyncd. By default
# this is on, ensuring that BackupPC will refuse to connect to an rsyncd on the client that
# is not password protected.
#
# [*rsync_csum_cache_verify_prob*]
# When rsync checksum caching is enabled (by adding the --checksum-seed=32761 option to
# rsync_args), the cached checksums can be occasionally verified to make sure the file
# contents matches the cached checksums.
#
# [*rsync_args*]
# Arguments to rsync for backup.
#
# [*rsync_restore_args*]
# Arguments to rsync for restore.
#
# [*backup_files_only*]
# List of directories or files to backup. If this is defined, only these
# directories or files will be backed up.
#
# [*backup_files_exclude*]
# List of directories or files to exclude from the backup. For xfer_method smb,
# only one of backup_files_exclude and backup_files_only can be specified per share.
# If both are set for a particular share, then backup_files_only takes precedence and
# backup_files_exclude is ignored.
#
# [*dump_pre_user_cmd*]
# Optional command to run before a dump.
#
# [*dump_post_user_cmd*]
# Optional command to run after a dump.
#
# [*dump_pre_share_cmd*]
# Optional command to run before a dump of a share.
#
# [*dump_post_share_cmd*]
# Optional command to run after a dump of a share.
#
# [*restore_pre_user_cmd*]
# Optional command to run before a restore.
#
# [*restore_post_user_cmd*]
# Optional command to run after a restore.
#
# [*user_cmd_check_status*]
# Whether the exit status of each PreUserCmd and PostUserCmd is checked.
#
# [*hosts_file_dhcp*]
# The way hosts are discovered has changed and now in most cases you should
# use the default of 0 for the DHCP flag, even if the host has a dynamically
# assigned IP address.
#
# [*hosts_file_most_users*]
# Additional user names, separate by commas and with no white space, can be
# specified. These users will also have full permission in the CGI interface
# to stop/start/browse/restore backups for this host. These users will not be
# sent email about this host.
#
# [*sudo_prepend*]
# Prepend a command to the sudo command, as run in backuppc.sh. This is mostly
# useful for running the backup via nice or ionice, in order to reduce the 
# impact of large backups on the client.
#
# === Examples
#
#  See tests folder.
#
# === Authors
#
# Scott Barr <gsbarr@gmail.com>
#
class backuppc::client (
  $ensure                = 'present',
  $config_name           = $facts['networking']['fqdn'],
  $backuppc_hostname     = '',
  $client_name_alias     = false,
  $system_account        = 'backup',
  $system_home_directory = '/var/backups',
  $system_additional_commands = [],
  $system_additional_commands_noexec = [],
  $manage_sudo           = false,
  $manage_rsync          = true,
  $full_period           = false,
  $full_keep_cnt         = false,
  $full_age_max          = false,
  $incr_period           = false,
  $incr_keep_cnt         = false,
  $incr_age_max          = false,
  $incr_levels           = [],
  $incr_fill             = false,
  $partial_age_max       = false,
  $blackout_bad_ping_limit = false,
  $ping_max_msec         = false,
  $ping_cmd              = false,
  $blackout_good_cnt     = false,
  $blackout_periods      = false,
  $backups_disable       = false,
  $xfer_method           = 'rsync',
  $xfer_loglevel         = '1',
  $smb_share_name        = '',
  $smb_share_username    = '',
  $smb_share_passwd      = '',
  $smb_client_full_cmd   = '',
  $smb_client_incr_cmd   = '',
  $smb_client_restore_cmd = '',
  $tar_share_name        = '',
  $tar_client_cmd        = '',
  $tar_full_args         = '',
  $tar_incr_args         = '',
  $tar_client_restore_cmd = '',
  $rsync_client_cmd      = '',
  $rsync_client_restore_cmd = '',
  $rsync_share_name      = '',
  $rsyncd_client_port    = false,
  $rsyncd_user_name      = '',
  $rsyncd_passwd         = '',
  $rsyncd_auth_required  = false,
  $rsync_csum_cache_verify_prob = false,
  $rsync_args            = [],
  $rsync_restore_args    = [],
  $backup_files_only     = [],
  $backup_files_exclude  = [],
  $dump_pre_user_cmd     = '',
  $dump_post_user_cmd    = '',
  $dump_pre_share_cmd    = '',
  $dump_post_share_cmd   = '',
  $restore_pre_user_cmd  = '',
  $restore_post_user_cmd = '',
  $user_cmd_check_status = true,
  $email_notify_min_days = false,
  $email_from_user_name  = '',
  $email_admin_user_name = '',
  $email_destination_domain = '',
  $email_notify_old_backup_days = false,
  $hosts_file_dhcp       = 0,
  $hosts_file_user       = 'backuppc',
  $hosts_file_more_users = '',
  $sudo_prepend          = '',
    ) {
  include backuppc::params

  validate_re($ensure, '^(present|absent)$',
  'ensure parameter must have a value of: present or absent')

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    default   => absent,
  }

  if empty($backuppc_hostname) {
    fail('Please provide the hostname of the node that hosts backuppc.')
  }

  validate_re($xfer_method, '^(smb|rsync|rsyncd|tar)$',
  'Xfer_method parameter must have value of: smb, rsync, rsyncd or tar')
  if $blackout_periods != false {
      validate_array($blackout_periods)
  }
  validate_re($xfer_loglevel, '^[0-2]$',
  'Xfer_loglevel parameter must be a 0, 1 or 2')

  $real_incr_fill = bool2num($incr_fill)
  $real_backups_disable = bool2num($backups_disable)
  $real_rsyncd_auth_required = bool2num($rsyncd_auth_required)
  $real_user_cmd_check_status = bool2num($user_cmd_check_status)

  # With these xfer_methods we require sudo to grant access
  # from the backuppc server to this client. It may be managed
  # elsewhere so we allow it to be overridden with the manage_sudo
  # parameter.
  if $xfer_method in ['rsync', 'tar'] and ! empty($system_account)
  {
    validate_absolute_path($system_home_directory)

    if $xfer_method == 'rsync' {
      if $manage_rsync {
        package { 'rsync':
          ensure => installed,
        }
      }
      $sudo_command_noexec = '/usr/bin/rsync'
    }
    else {
      $sudo_command_noexec = $backuppc::params::tar_path
    }

    if $manage_sudo {
      package { 'sudo':
        ensure => installed,
        before => File['/etc/sudoers.d/backuppc'],
      }
      file { '/etc/sudoers.d/':
        ensure  => directory,
        purge   => false,
        require => Package['sudo'],
      }
      file_line { 'sudo_includedir':
        ensure  => present,
        path    => '/etc/sudoers',
        line    => '#includedir /etc/sudoers.d',
        require => Package['sudo'],
      }
    }

    if ! empty($system_additional_commands) {
      $additional_sudo_commands = join($system_additional_commands, ', ')
      $sudo_commands = $additional_sudo_commands
    } else {
      $sudo_commands = undef
    }

    if ! empty($system_additional_commands_noexec) {
      $additional_sudo_commands_noexec = join($system_additional_commands_noexec, ', ')
      $sudo_commands_noexec = "${sudo_command_noexec}, ${additional_sudo_commands_noexec}"
    } else {
      $sudo_commands_noexec = $sudo_command_noexec
    }

    if ! empty($sudo_commands) {
      file { '/etc/sudoers.d/backuppc':
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => "${system_account} ALL=(ALL:ALL) NOPASSWD: ${sudo_commands}\n",
      }
    } else {
      file { '/etc/sudoers.d/backuppc':
        ensure  => 'absent',
      }
    }

    file { '/etc/sudoers.d/backuppc_noexec':
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      content => "${system_account} ALL=(ALL:ALL) NOEXEC:NOPASSWD: ${sudo_commands_noexec}\n",
    }

    user { $system_account:
      ensure     => $ensure,
      home       => $system_home_directory,
      managehome => true,
      shell      => '/bin/bash',
      comment    => 'BackupPC',
      system     => true,
      password   => '*',
    }

    file { "${system_home_directory}/.ssh":
      ensure  => $directory_ensure,
      mode    => '0700',
      owner   => $system_account,
      group   => $system_account,
    }

    file { "${system_home_directory}/.ssh/known_hosts":
      ensure  => 'link',
      target  => '/dev/null',
      force   => 'true',
      require => File["${system_home_directory}/.ssh"],
    }

    file { "${system_home_directory}/backuppc.sh":
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('backuppc/client/backuppc.sh.erb'),
      require => User[$system_account],
    }

    Ssh_authorized_key <<| tag == "backuppc_${backuppc_hostname}" |>> {
      ensure  => $ensure,
      user    => $system_account,
      require => File["${system_home_directory}/.ssh"]
    }

    file { "/etc/ssh/ssh_keys/${system_account}.pub":
      ensure  => $ensure,
      owner   => $system_account,
      mode    => "0600",
      require => User[$system_account],
    } ->
    Ssh_authorized_key <<| tag == "backuppc_${backuppc_hostname}" |>> {
      ensure  => $ensure,
      target  => "/etc/ssh/ssh_keys/${system_account}.pub"
    }

  }

  # if $facts['networking']['fqdn'] != $backuppc_hostname {
  # @@sshkey { "bpc-${facts['networking']['fqdn']}":
  # ensure => $ensure,
  # type   => 'ssh-rsa',
  # key    => $facts['ssh']['rsa']['key'],
  # tag    => "backuppc_sshkeys_${backuppc_hostname}",
  # }
  # }

  if $ensure == 'present' {
    @@augeas { "backuppc_host_${config_name}-create":
      context => '/files/etc/backuppc/hosts',
      changes => template("${module_name}/host-augeas-create.erb"),
      lens    => 'BackupPCHosts.lns',
      incl    => '/etc/backuppc/hosts',
      onlyif  => "match *[host = '${config_name}'] size == 0",
      before  => Augeas["backuppc_host_${config_name}-update"],
      tag     => "backuppc_hosts_${backuppc_hostname}",
    }
    @@augeas { "backuppc_host_${config_name}-update":
      context => '/files/etc/backuppc/hosts',
      changes => template("${module_name}/host-augeas-update.erb"),
      lens    => 'BackupPCHosts.lns',
      incl    => '/etc/backuppc/hosts',
      onlyif  => "match *[host = '${config_name}'] size > 0",
      tag     => "backuppc_hosts_${backuppc_hostname}",
    }
  }

  @@file { "${backuppc::params::config_directory}/pc/${config_name}.pl":
    ensure  => $ensure,
    content => template("${module_name}/host.pl.erb"),
    owner   => 'backuppc',
    group   => $backuppc::params::group_apache,
    mode    => '0640',
    tag     => "backuppc_config_${backuppc_hostname}"
  }
}
