# init.pp
# Calls the python package

class python {

    class {'python::package':}

}