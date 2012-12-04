# Puppet-Python #

An app for managing python applications, like Flask and Django, with puppet.

The purpose of these puppet scripts is to create an initial environment. Further manipulation (i.e., deploying new code; changing packages) is not covered here.  We may open source a Fabric script that does this in the future.

The goal of this particular package is to abstract the building of python virtual environments, nginx configurations and uwsgi containers for python apps.

## Requirements ##

[puppetlabs-nginx](https://github.com/washingtonpost/puppetlabs-nginx)
[puppet-uwsgi](https://github.com/washingtonpost/puppet-uwsgi)
[puppet-git](https://github.com/washingtonpost/puppet-git)
[stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

## Usage ##

### Django ###

Basic django usage is very simple, and requires only a few parameters.

First, make sure that you set up an nginx vhost instance:

    include python, nginx

    nginx::resource::vhost {'my_python_env':
        www_root => '/var/www',
    }


Then, create a django instance.

    python::django {'my_virtual_environment':
        # source url
        source => 'git@github.com:my_user/my-pkg.git',
        # required for cloning into the correct directory
        repo_name => 'my-pkg',
        # settings module that the uwsgi container will run
        settings_module => 'my_pkg.settings',
        # nginx location (default is `/`)
        location => '/app',
        # NGINX vhost (from the above code block)
        vhost => 'my_python_env',
    }


### Flask ###

Coming soon!