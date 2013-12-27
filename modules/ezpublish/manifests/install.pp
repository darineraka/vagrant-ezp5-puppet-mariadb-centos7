class ezpublish::install {
  $www = '/var/www/html'
  $ezpublish_src = 'http://share.ez.no/content/download/154571/912584/version/1/file/ezpublish5_community_project-2013.11-gpl-full.tar.gz'
  $ezpublish_folder = 'ezpublish5'
  $ezpublish = 'ezpublish.tar.gz'
  $package_index = 'http://packages.ez.no/ezpublish/5.3/5.3.0alpha1/index.xml'
  exec { "download":
    command => "/usr/bin/wget $ezpublish_src -O $www/$ezpublish",
  } ~>
  exec { "create_folder":
    command => "/bin/mkdir $www/$ezpublish_folder",
    refreshonly => true,
    returns => [ 0, 1, 2, '', ' ']
  } ~>
  exec { "extract":
    command => "/bin/tar --strip-components=1 -xzf $www/$ezpublish -C $www/$ezpublish_folder",
    refreshonly => true,
    returns => [ 0, 1, 2, '', ' ']
  } ~>
  exec { "setfacl-R":
    command => "/usr/bin/setfacl -R -m u:apache:rwx -m u:apache:rwx $www/$ezpublish_folder/ezpublish/{cache,logs,config} $www/$ezpublish_folder/ezpublish_legacy/{design,extension,settings,var} web",
    refreshonly => true,
    returns => [ 1 ]
  } ~>
  exec { "setfacl-dR":
    command => "/usr/bin/setfacl -dR -m u:apache:rwx -m u:vagrant:rwx $www/$ezpublish_folder/ezpublish/{cache,logs,config} $www/$ezpublish_folder/ezpublish_legacy/{design,extension,settings,var} web",
    refreshonly => true,
    returns => [ 0, 1, 2, '', ' ']
  } ~>
  exec { "remove_cache":
    command => "/bin/rm -rf $www/$ezpublish_folder/ezpublish/cache/*",
  } ~>
  exec { "assets_install":
    command => "/usr/bin/php $www/$ezpublish_folder/ezpublish/console assets:install --symlink $www/$ezpublish_folder/web",
  } ~>
  exec { "legacy_assets":
    command => "/usr/bin/php $www/$ezpublish_folder/ezpublish/console ezpublish:legacy:assets_install --symlink $www/$ezpublish_folder/web",
  } ~>
  exec { "assetic_dump":
    command => "/usr/bin/php $www/$ezpublish_folder/ezpublish/console assetic:dump",
  } ~>
  file { "$www/$ezpublish_folder/ezpublish_legacy/kickstart.ini":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/kickstart.ini.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '777',
  } ~>
  file { "$www/$ezpublish_folder/install_packages.sh":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/install_packages.sh.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '777'
  } ~>
  exec { "run_install_packages":
    command => "./install_packages.sh | sh",
    cwd  => "$www/$ezpublish_folder",
    path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin:$www/$ezpublish_folder",
  } ~>
  exec { "download_index.xml":
    command => "/usr/bin/wget $package_index -O $www/$ezpublish/ezpublish_legacy/var/storage/packages/eZ-systems/index.xml",
    refreshonly => true,
    returns => [ 0, 1, 2, '', ' ']
  }
}