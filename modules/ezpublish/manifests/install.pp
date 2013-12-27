class ezpublish::install {
  $www = '/var/www/html'
  $ezpublish_src = 'http://share.ez.no/content/download/154571/912584/version/1/file/ezpublish5_community_project-2013.11-gpl-full.tar.gz'
  $ezpublish_folder = 'ezpublish5'
  $ezpublish = 'ezpublish.tar.gz'
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
  file { "$www/$ezpublish_folder/ezpublish/config/ezpublish_prod.yml":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/ezpublish_prod.yml.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '666',
  } ~>
  file { "$www/$ezpublish_folder/ezpublish/config/ezpublish.yml":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/ezpublish.yml.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '666',
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
  exec { "create_folders":
    command => "/bin/mkdir -p $www/$ezpublish_folder/ezpublish_legacy/settings/override && /bin/mkdir -p $www/$ezpublish_folder/ezpublish_legacy/settings/siteaccess/eng && /bin/mkdir -p $www/$ezpublish_folder/ezpublish_legacy/settings/siteaccess/ezdemo_site && /bin/mkdir -p $www/$ezpublish_folder/ezpublish_legacy/settings/siteaccess/ezdemo_site_admin",
    refreshonly => true,
    returns => [ 0, 1, 2, '', ' ']
  } ~>
  file { "$www/$ezpublish_folder/ezpublish_legacy/settings/override/site.ini.append.php":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/override_site.ini.append.php.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '666',
  } ~>
  file { "$www/$ezpublish_folder/ezpublish_legacy/settings/siteaccess/eng/site.ini.append.php":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/ezdemo_site.ini.append.php.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '666',
  } ~>
  file { "$www/$ezpublish_folder/ezpublish_legacy/settings/siteaccess/ezdemo_site/site.ini.append.php":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/ezdemo_site.ini.append.php.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '666',
  } ~>
  file { "$www/$ezpublish_folder/ezpublish_legacy/settings/siteaccess/ezdemo_site_admin/site.ini.append.php":
    ensure => file,
    content => template('/tmp/vagrant-puppet/modules-0/ezpublish/manifests/setup/admin_site.ini.append.php.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '666',
  } ~>
  exec { "kernel_schema":
    command => "/usr/bin/mysql -uezp -pezp ezp < $www/$ezpublish_folder/ezpublish_legacy/kernel/sql/mysql/kernel_schema.sql",
    returns => [ 0, 1, '', ' ']
  } ~>
  exec { "cleandata":
    command => "/usr/bin/mysql -uezp -pezp ezp < $www/$ezpublish_folder/ezpublish_legacy/kernel/sql/common/cleandata.sql",
    returns => [ 0, 1, '', ' ']
  } ~>
  exec { "regenerateautoloads":
    command => "/usr/bin/php bin/php/ezpgenerateautoloads.php --extension",
    cwd  => "$www/$ezpublish_folder/ezpublish_legacy",
    path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin:$www/$ezpublish_folder",
  }
}