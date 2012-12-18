# python::webapp::django

define python::webapp::django(
    $settings_module,
    $location,
    $vhost,
    $source=undef,
    $repo_name=undef,
    $requirements='requirements.txt',
    $config_only=false,
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

    # If config is false, then it also clones the repo and sets up the environment
    if ($config_only == false) {
        # Clone the code repo
        git::commands::clone { $name:
            repo_name => $repo_name,
            source => $source,
            path => $code_path,
            user => "${python::params::user}",
            require => Uwsgi::Instance::Basic[$name]
        }

        # Initialize the environment and install requirements
        python::environment { $name:
            source => $source,
            requirements => "${code_path}${repo_name}/${requirements}",
            pythonpath => $pythonpath,
            notify => Class['uwsgi::service'],
            require => Git::Commands::Clone[$name]
        }
    }
}