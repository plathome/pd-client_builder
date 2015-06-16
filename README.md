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
# rake1.9.1 all
# ls deb/*.deb
```

### post-process ###

```
$ sudo rm -rf build/ cache/ deb/
```

### NOTE ###

* Suppress Lintian errors, Exec below before `rake1.9.1 all` (Building w/ Docker, included this process)

```
# rake1.9.1 ~/.devscripts ~/.lintian/profiles/ignore-opt-dir/main.profile
```


Using w/ Docker
---------------

```
$ git clone https://github.com/plathome/pd-client_builder.git /path/to/dir
$ cd /path/to/dir
$ make docker_build
$ make docker_run
$ cp deb/*.deb /path/to/any
```

### post-process ###

```
$ sudo rm -rf build/ cache/ deb/
```

### NOTE ###

* Builder using overlayfs. Therefore, cannot use on overlayfs base environment. (docker, lxc and so on)
* `make` has *ARCH* var. That is target architecture name, default is *i386*. e.g.) `make -e ARCH=amd64 docker_build`


NOTE: Update Upstream package
-----------------------------

* EDIT: Rakefile
* `(cd {package}-debian/debian ; dch -v UPSTREAM_VERSION-1 "RELEASE_NOTE" ; dch -r "")`
* `make docker_run`

NOTE: Initial dh\_make
----------------------

```
dh_make -s -y
rm debian/*.ex debian/*.EX debian/docs debian/README.*
```

EOT

