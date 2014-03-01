group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

exec { "apt-get initial update":
    command => 'apt-get update'
}

$default_packages = [ "strace", "sysstat", "git", "subversion" ]
package { $default_packages :
    ensure => "latest"
}

# Adds URIs to local etc/hosts
host { 'dev.osemtek.com':
    ip => '127.0.0.1',
}

package {
    [
      "nginx-full"
    ]: ensure => installed,
}

service {
    "nginx":
      enable     => true,
      ensure     => running,
      hasrestart => true,
      subscribe  => [Package["nginx-full"]],
}

exec {
    "service nginx restart":
      command      => "service nginx restart",
      refreshonly  => true,
}

file {
    "/usr/share/nginx/www/sites":
      ensure => "directory",
      recurse => true
}

file {
    [        
      "/etc/nginx/conf.d"
    ]: 
    ensure => "directory", 
      require => [Package["nginx-full"]],
    recurse => true
}

file { "/etc/nginx/sites-enabled" :
      ensure => "directory",
      recurse => true,
      require => [Package["nginx-full"]],
      notify => Service["nginx"],
}

file { "/etc/nginx/nginx.conf":
      source => "puppet:///modules/nginx-web/etc/nginx/nginx.conf",
      owner  => "root",
      group  => "root",
      mode   => 644,
      require => [Package["nginx-full"]]
}

file { "/etc/nginx/sites-available/default":
      source => "puppet:///modules/nginx-web/etc/nginx/sites-available/default",
      owner  => "root",
      group  => "root",
      mode   => 644,
      require => [Package["nginx-full"]]
}

package { 'apache2':
    ensure => present,
}

service { 'apache2':
    ensure  => stopped,
    enable  => false,
    require => Package['apache2']
}->

package { "php5-fpm" :
    ensure => "latest",
    notify => [Service['nginx']],
    require => [Package['nginx-full']]
}

file { '/var/log/nginx':
    ensure => directory,
    recurse => true
}->
file { '/var/log/nginx/osemtek.com':
    ensure => directory,
    recurse => true
}->
file { '/var/log/nginx/osemtek.com/access.log':
    ensure => present,
    require => Package['nginx-full'],
    recurse => true
}->
file { '/var/log/nginx/osemtek.com/error.log':
    ensure => present,
    require => Package['nginx-full'],
    notify => Service['nginx'],
    recurse => true
}

class {'apt':
  always_apt_update => true,
}

Class['::apt::update'] -> Package <|
    title != 'python-software-properties'
and title != 'software-properties-common'
|>

    apt::key { '4F4EA0AAE5267A6C': }

apt::ppa { 'ppa:ondrej/php5-oldstable':
  require => Apt::Key['4F4EA0AAE5267A6C']
}

package { [
    'build-essential',
    'vim',
    'curl',
    'git-core',
    'mc'
  ]:
  ensure  => 'installed',
}

#add repo from ServerGrove that has some php5.4 modules and things
file { '/etc/apt/sources.list.d/servergrove.list':
    ensure => present,
    content => "deb http://repos.servergrove.com/servergrove-ubuntu-precise precise main",
}->

exec { 'download servergrove public key':
    command => 'curl -O http://repos.servergrove.com/servergrove-ubuntu-precise/servergrove-ubuntu-precise.gpg.key',
}->
exec { 'add servergrove public key':
    command => 'apt-key add servergrove-ubuntu-precise.gpg.key',
}->

exec { 'add-apt-repository ppa:ondrej/php5-oldstable':
    command => 'add-apt-repository ppa:ondrej/php5-oldstable',
}->

exec { 'apt-get update':
    command => 'apt-get update',
}->

package { "php-pear":
    ensure => "installed"
}->
exec { "configure pear auto_discover":
    command => 'pear config-set auto_discover 1',
}->
exec { "upgrade pear":
    command => 'pear upgrade pear',
}

package { "php5-mysql" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php5-cli" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php5-curl" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php5-intl" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php5-mcrypt" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php5-gd" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php-apc" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php5-dev" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

package { "php5-xdebug" :
    ensure => "latest",
    notify => Service["nginx"],
    require => [Package['php5-fpm']]
}

exec { 'setup-xdebug-config':
    command => 'cat <<EOF >>
                /etc/php5/conf.d/20-xdebug.ini
                xdebug.remote_enable = 1
                xdebug.remote_connect_back = 1
                xdebug.remote_host=192.168.33.20
                xdebug.idekey = "vagrant"
                xdebug.remote_autostart = 0
                xdebug.remote_port = 9000
                xdebug.remote_handler=dbgp
                xdebug.remote_log="/tmp/xdebug.log"
                xdebug.profiler_enable=false
                xdebug.profiler_output_dir="/tmp"
                ',
    require => [Package['php5-xdebug']],
    notify => Service['nginx']
}


$web_packages = [ "gcc", "make", "memcached" ]
package { $web_packages :
    ensure => "latest",
}

class { 'composer':
    command_name => 'composer',
    target_dir   => '/usr/local/bin',
    auto_update => true,
    require => Package['php5-fpm', 'curl'],
}

# Install bitbucket deployment key
file { "/home/vagrant/.ssh/id_rsa":
    source => "puppet:///commonfiles/sgdeploykey/id_rsa",
    owner  => "vagrant",
    mode   => 600
}->
file { "/home/vagrant/.ssh/id_rsa.pub":
    source => "puppet:///commonfiles/sgdeploykey/id_rsa.pub",
    owner  => "vagrant",
    mode   => 600
}->
file { "/home/vagrant/.ssh/known_hosts":
    source => "puppet:///commonfiles/known_hosts",
    owner  => "vagrant",
    mode   => 644
}->
exec { 'install-bitbucket-cert':
    command => '/bin/sh -c \'eval "$(ssh-agent)"; su vagrant; ssh-add /home/vagrant/.ssh/id_rsa\''
    #command => 'ssh-add /home/vagrant/.ssh/id_rsa'
}

class { "mysql":
    root_password => '',
}->

# Create Oreo Database
mysql::grant { 'create-osemtek-database':
    mysql_db         => 'osemtek',
    mysql_user       => 'root',
    mysql_password   => '',
    mysql_privileges => 'ALL',
    mysql_host       => '%'
}->    
mysql::grant { 'create-osemtek-test-database':
    mysql_db         => 'osemtek-test',
    mysql_user       => 'root',
    mysql_password   => '',
    mysql_privileges => 'ALL',
    mysql_host       => '%',
}->    
mysql::grant { 'create-osemtek-dev-database':
    mysql_db         => 'osemtek-dev',
    mysql_user       => 'root',
    mysql_password   => '',
    mysql_privileges => 'ALL',
    mysql_host       => '%',
}


mysql::augeas {
   'mysqld/bind-address':
      value  => '0.0.0.0';
}

# Mongo Install
exec { 'mongo-key':
  command => 'sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10'
}->
exec { 'mongo-source':
  command => 'echo \'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen\' | sudo tee /etc/apt/sources.list.d/mongodb.list'
}->
exec { 'mongo-aptget-update':
  command => 'sudo apt-get update'
}->
exec { 'mongo-install':
  command => 'sudo apt-get install mongodb-10gen'
}

exec { 'pecl-mongo-install':
    command => 'pecl install mongo',
    unless => "pecl info mongo",
    notify => [Package['php5-fpm']],
    require => Package['php-pear'],
}