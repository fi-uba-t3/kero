
.DEFAULT: all
all: build

build:
	sudo docker build -t juanfresia/taller3-test-vnc .
.PHONY: build

push:
	sudo docker push juanfresia/taller3-test-vnc
.PHONY: push

build-test:
	sudo docker build -t juanfresia/taller3-test-vnc:test .
.PHONY: build-test

push-test:
	sudo docker push juanfresia/taller3-test-vnc:test
.PHONY: push-test
