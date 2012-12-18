define python::webapp::environment(
    $source,
    $requirements,
    $log=false,
    $tmp_dir='/tmp/',
    $pythonpath=[],
) {
    # Create the virtualenv
    exec {"venv_init_${name}":
        command => "${python::params::init_venv_script} ${python::params::location}${name}",
        path => $path,
        user => "${python::params::user}",
        logoutput => $log,
        creates => "${python::params::location}${name}/bin",
    }

    # Add additional elements to the path using extra.pth in the site-packages folder
    file {"add_to_path_${name}":
        ensure => present,
        path => "${python::params::location}${name}/lib/python2.7/site-packages/extra.pth",
        content => template('python/pythonpath.erb'),
        require => Exec["venv_init_${name}"],
    }

    # Install all of the python requirements
    exec {"install_${name}":
        command => "${python::params::location}${env_name}/bin/pip -v --log ${tmp_dir}pip.log install --use-mirrors -r ${requirements}",
        path => $path,
        logoutput => $log,
        user => "${python::params::user}",
        cwd => $tmp_dir,
        require => Exec["venv_init_${name}"],
    }
}
