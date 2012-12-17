# python::django

define python::django(
    $source,
    $repo_name,
    $settings_module,
    $location,
    $vhost,
    $pythonpath=[],
    $upgrade=false,
    $code_path="${python::params::location}",
) {
    # include the necessary libs
    include nginx, uwsgi, git

    # Build a uwsgi instance
    # All of the requirements here are needed for Django
    # An additional param, pythonpath, should probably be added.
    uwsgi::instance::basic {$name:
        params => {
            'chdir' => "\"${code_path}${name}\"",
            'home' => "\"${code_path}${name}\"",
            'env' => "\"DJANGO_SETTINGS_MODULE=${settings_module}\"",
            'module' => '"django.core.handlers.wsgi:WSGIHandler()"'
        }
    }

    # Create an nginx instance
    nginx::resource::location { $name:
        vhost => $vhost,
        proxy => "unix:/tmp/uwsgi.${name}.sock",
        uwsgi => true,
        location => "${location}/",
        uwsgi_params => ["SCRIPT_NAME ${location}"],
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