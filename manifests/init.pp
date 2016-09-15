class secrets_server {
	if ! defined(File["/opt/max"]) {
		file { "/opt/max":
			ensure => directory,
		}
	}

	vcsrepo { "/opt/max/secrets":
		ensure => present,
		provider => git,
		source => "https://github.com/thexa4/secrets-server.git",
		require => File["/opt/max"],
	}

	file { "/opt/max/secrets/data":
		ensure => "directory",
		owner => "www-data",
		group => "www-data",
		mode => "0750",
		require => Vcsrepo["/opt/max/secrets"],
	}
	
	class { 'apache':
		mpm_module => 'prefork',
		default_vhost => false,
		require => Vcsrepo["/opt/max/secrets"],
	}
	
	$host = $trusted['certname']
	apache::vhost { "$host-insecure":
		port	=> '80',
		docroot	=> '/opt/max/secrets/public',

		override => ['All'],
	}

	exec { "create secrets_server config.php":
		creates => "/opt/max/secrets/config.php",
		exec => "/bin/cp /opt/max/secrets/config.php.sample /opt/max/secrets/config.php",
		require => Vcsrepo["/opt/max/secrets"],
	}

	apache::vhost { "$host-secure":
		port	=> '443',
		docroot	=> '/opt/max/secrets/public',
		override => ['All'],
		
		ssl	=> true,
		ssl_cert	=> '/etc/ssl/certs/host.crt',
		ssl_key => '/etc/ssl/private/host.key',
		ssl_ca	=> '/etc/ssl/certs/host-ca.crt',
		ssl_certs_dir => false,
		ssl_verify_client => 'optional',
	}

	class { "apache::mod::php": }
	class { "apache::mod::rewrite": }
}
