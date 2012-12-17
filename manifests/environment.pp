define python::environment(
    $source,
    $pythonpath=[],
) {
    # Create the virtualenv
    exec {"venv_init_${name}":
        command => "${python::params::init_venv_script} ${python::params::location}${name}",
        path => $path,
        user => "${python::params::user}",
        logoutput => true,
        creates => "${python::params::location}${name}/bin",
    }

    file {"add_to_path_${name}":
        ensure => present,
        path => "${python::params::location}${name}/lib/python2.7/site-packages/extra.pth",
        content => template('python/pythonpath.erb'),
        require => Exec["venv_init_${name}"],
    }

    # Install all of the python requirements
    exec {"install_${name}":
        command => "${python::params::location}${name}/bin/pip -v --log /tmp/pip.${name}.log install -e git+${source}#egg=${name}",
        path => $path,
        logoutput => true,
        user => "${python::params::user}",
        cwd => '/tmp/',
        require => Exec["venv_init_${name}"],
    }

}
