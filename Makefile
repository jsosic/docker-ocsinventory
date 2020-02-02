OCS_VERSION ?= 2.6
IMAGE_NAME  ?= jsosic/ocsinventory
IMAGE_TAG   ?= $(OCS_VERSION)
BRANCH_HASH ?= $(shell git rev-parse --short HEAD)
BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD)
TIMEZONE    ?= Europe/Zagreb

all: build

build:
	docker build --pull \
		--build-arg "OCS_VERSION=$(OCS_VERSION)" \
		--build-arg "TIMEZONE=$(TIMEZONE)" \
		-t "$(IMAGE_NAME):$(IMAGE_TAG)" \
		-t "$(IMAGE_NAME):$(BRANCH_HASH)" \
		-t "$(IMAGE_NAME):$(BRANCH_NAME)" .

push:
	docker push "$(IMAGE_NAME):$(IMAGE_TAG)"

clean:
	docker-compose down

run:
	docker-compose up --pull || docker-compose up --build
