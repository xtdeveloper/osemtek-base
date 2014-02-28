
#Set default path for Exec calls
Exec {
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/']
}

# Install some default packages
$default_packages = [ "strace", "sysstat", "git", "subversion" ]
package { $default_packages :
  ensure => "latest"
}

exec { "apt-get update":
  command => 'apt-get update'
}

package {'curl':
  provider => apt,
  ensure   => latest,
  require  => Exec['apt-get update']
}

exec { "add-apt-repository ppa:webupd8team/java":
  command => 'add-apt-repository -y ppa:webupd8team/java'
}->
exec { "apt-get update2":
  command => 'apt-get update'
}->
exec { "apt-get-accept-license1":
  command => "echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections"
}->
exec { "apt-get-accept-license2":
  command => "echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections"
}->
class {"elasticsearch":
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb',
  java_install => true,
  java_package => 'oracle-java7-installer',
  ensure => "present",
  status => "enabled",
  restart_on_change => true
}->

exec { "install bigdesk":
  require => Service['elasticsearch'],
  command => 'sudo /usr/share/elasticsearch/bin/plugin -install lukas-vlcek/bigdesk'
}->

exec { "install kopf":
  require => Service['elasticsearch'],
  command => 'sudo /usr/share/elasticsearch/bin/plugin -install lmenezes/elasticsearch-kopf'
}