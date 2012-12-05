class python::params {
    $init_venv_script='/usr/local/bin/virtualenv'
    $init_venv_script_path='/usr/local/bin/'
    $path=['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/']
    $location='/opt/python/'
    $log='/var/log/python/'
    $user='ubuntu'
    $group='ubuntu'
    $python_c_packages=['python-dev', 'libxml2-dev', 'libxslt-dev']
    $extra_c_packages=[]
}
