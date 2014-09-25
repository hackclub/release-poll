TAG=hackedu/release-poll

.PHONY: build push

build:
	docker build -t $(TAG) .

push:
	docker push $(TAG)
