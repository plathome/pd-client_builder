# NOTE: overwrite var: e.g.) make -e TAG=foo:bar docker_build
ARCH=i386
TAG=pd-client_builder:$(ARCH)

.PHONY: all
all: ;

.PHONY: setup
# NOTE: Remove "ruby" because not to overlap by rbenv's ruby
# Using "ruby1.9.1" and "rake1.9.1"
setup:
	apt-get update
	apt-get install -y build-essential libssl-dev libncurses5-dev libreadline6-dev libtinfo-dev libyaml-dev zlib1g-dev git curl devscripts dh-make rsync socat rake
	update-alternatives --remove-all ruby

.PHONY: docker_build
docker_build:
	docker build --file Dockerfile.$(ARCH) --force-rm --tag $(TAG) .
	@echo ""
	@echo "NEXT: make -e TAG=$(TAG) docker_run"

.PHONY: docker_run
docker_run:
	docker run --rm --privileged=true -v ${PWD}/deb:/tmp/pd-client_builder/deb $(TAG)

.PHONY: docker_rmi
docker_rmi:
	docker rmi $(TAG)

