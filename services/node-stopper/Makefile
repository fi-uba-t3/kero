VERSION?=0.0.2

.DEFAULT: all
all: build

build:
	sudo docker build -t juanfresia/node-stopper:$(VERSION) .
.PHONY: build

push:
	sudo docker push juanfresia/node-stopper:$(VERSION)
.PHONY: push

