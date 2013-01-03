# Usage:

# Call the webapp method and pass the correct parameters in order for it to install

# python::django {'VIRTUAL_ENV_NAME':
#     requirements => 'LOCATION_OF_REQUIREMENTS_FILE (INSIDE REPO)',
#     source => 'GIT_REPO',
#     code_path => 'WHERE_CODE_LIVES',
# }



define python::flask(
    $source,
    $repo_name,
    $flask_config,
    $pkg,
    $location,
    $vhost,
    $callable='app',
    $requirements='requirements.txt',
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
            'chdir' => "\"${code_path}${repo_name}/${pkg}/\"",
            'home' => "\"${code_path}${name}/${pkg}/\"",
            'env' => "\"FLASK_ENV=${flask_config}\"",
            'module' => "\"${name}\"",
            'callable' => "\"${callable}\"",
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
        env_name => $name,
        upgrade => $upgrade,
        requirements => "${code_path}${repo_name}/${pkg}/${requirements}",
        pythonpath => $pythonpath,
        # Include uwsgi (in order to notify the service that the requirements have finished installing)
        notify => Class['uwsgi::service'],
        require => Git::Commands::Clone[$name]

    }
}