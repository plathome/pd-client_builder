PD Client deb package builder
=============================

* pd-emitter
* pd-emitter-plugin-\*

and Engine(pd-ruby), Supervisor(pd-emitter-daemon)


Using
-----

* Under root user (Due to using `/opt` dir. Or user writable `/opt`)
* Internet connection (apt, git clone, rbenv, gem)

```
# git clone https://github.com/plathome/pd-client_builder.git /path/to/dir
# cd /path/to/dir
# make setup
# rake1.9.1 dist-clean all
# ls deb/*.deb
```

### NOTE 1: ###

Lintian Error suppress, Exec below before `rake1.9.1 dist-clean all`

```
# rake1.9.1 ~/.devscripts ~/.lintian/profiles/ignore-opt-dir/main.profile
```

### NOTE 2: ###

Builder using *OverlayFS*. Overlayfs base virtual env (docker, lxc and any more) cannot use.


Using w/ Docker
---------------

```
$ git clone https://github.com/plathome/pd-client_builder.git /path/to/dir
$ cd /path/to/dir
$ make docker_build
$ make docker_run
$ ls deb/*.deb
```

NOTE: `sudo make docker_run` => `deb` dir is `/deb` (root user's `$HOME` is `/` :-p)

You can remove `deb/` if get `*.deb` files.

Remove docker image: `$ make docker_rmi`


NOTE: Initial dh\_make
----------------------

```
dh_make -s -y
rm debian/*.ex debian/*.EX debian/docs debian/README.*
dch -v 2.2.2-1nmu1
```

EOT

