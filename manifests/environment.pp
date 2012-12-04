define python::environment(
    $env_name,
    $requirements,
    $upgrade=true,
    $pythonpath=[],
) {
    if $upgrade == true {
        $pip_upgrade = '-U'
    } else {
        $pip_upgrade = ''
    }
    # Create the virtualenv
    exec {"venv_init_${name}":
        command => "${python::params::init_venv_script} ${python::params::location}${env_name}",
        path => $path,
        user => "${python::params::user}",
        logoutput => true,
    }

    file {"add_to_path_${name}":
        ensure => present,
        path => "${python::params::location}${env_name}/lib/python2.7/site-packages/extra.pth",
        content => template('django/pythonpath.erb'),
        require => Exec["venv_init_${name}"],
    }

    # Install all of the python requirements
    exec {"install_${name}":
        command => "${python::params::location}${env_name}/bin/pip -v --log /tmp/pip.log install ${pip_upgrade} --use-mirrors -r ${requirements}",
        path => $path,
        logoutput => true,
        user => "${python::params::user}",
        cwd => '/tmp/',
        require => Exec["venv_init_${name}"],
    }

}
