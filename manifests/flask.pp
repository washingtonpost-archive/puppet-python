# python::flask

define python::flask(
    $source,
    $repo_name,
    $flask_config,
    $location,
    $vhost,
    $pythonpath=[],
    $upgrade=false,
    $callable='app',
    $code_path="${python::params::location}",
) {
    # include the necessary libs
    include nginx, uwsgi, git

    # Build a uwsgi instance
    # All of the requirements here are needed for Django
    # An additional param, pythonpath, should probably be added.
    uwsgi::instance::basic {$name:
        params => {
            'chdir' => "\"${code_path}${repo_name}/\"",
            'home' => "\"${code_path}${name}\"",
            'env' => "\"FLASK_ENV=${flask_config}\"",
            'module' => "\"${name}\"",
            'callable' => "\"${callable}\"",

        }
    }

    # Create an nginx instance
    nginx::resource::location { $name:
        vhost => $vhost,
        proxy => "unix:/tmp/flask.${name}.sock",
        uwsgi => true,
        location => "${location}/",
        uwsgi_params => ["SCRIPT_NAME ${location}"],
        notify => Class['nginx::service'],
        require => Uwsgi::Instance::Basic[$name]
    }

    # Initialize the environment and install requirements
    python::environment { $name:
        source => $source,
        pythonpath => $pythonpath,
        # Include uwsgi (in order to notify the service that the requirements have finished installing)
        notify => Class['uwsgi::service'],
        require => Uwsgi::Instance::Basic[$name]

    }
}