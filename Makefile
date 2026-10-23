PHP_VERSION ?= 8.2.35
IMAGE_NAME ?= ferozcse/php-8.2-buster
VARIANTS = apache cli fpm supervisor dev fpm-apm

.PHONY: all build build-apache build-cli build-fpm build-dev build-supervisor build-fpm-apm push push-all push-fpm-apm test help

all: build

help:
	@echo "Available commands:"
	@echo "  make build               Build all image variants with PHP $(PHP_VERSION)"
	@echo "  make build-<variant>     Build specific variant (apache, cli, fpm, dev, supervisor)"
	@echo "  make push                Push all built image variants to Docker Hub ($(IMAGE_NAME))"
	@echo "  make push-<variant>      Push specific variant"
	@echo "  make test                Verify extensions in built images"
	@echo "  make build PHP_VERSION=8.2.36   Build with specific PHP version"

build:
	@./build.sh all $(PHP_VERSION) $(IMAGE_NAME)

build-apache:
	@./build.sh apache $(PHP_VERSION) $(IMAGE_NAME)

build-cli:
	@./build.sh cli $(PHP_VERSION) $(IMAGE_NAME)

build-fpm:
	@./build.sh fpm $(PHP_VERSION) $(IMAGE_NAME)

build-dev:
	@./build.sh dev $(PHP_VERSION) $(IMAGE_NAME)

build-supervisor:
	@./build.sh supervisor $(PHP_VERSION) $(IMAGE_NAME)

build-fpm-apm:
	@./build.sh fpm-apm $(PHP_VERSION) $(IMAGE_NAME)

push:
	@./build.sh push-all $(PHP_VERSION) $(IMAGE_NAME)

push-apache:
	@./build.sh push-variant apache $(PHP_VERSION) $(IMAGE_NAME)

push-cli:
	@./build.sh push-variant cli $(PHP_VERSION) $(IMAGE_NAME)

push-fpm:
	@./build.sh push-variant fpm $(PHP_VERSION) $(IMAGE_NAME)

push-dev:
	@./build.sh push-variant dev $(PHP_VERSION) $(IMAGE_NAME)

push-supervisor:
	@./build.sh push-variant supervisor $(PHP_VERSION) $(IMAGE_NAME)

push-fpm-apm:
	@./build.sh push-variant fpm-apm $(PHP_VERSION) $(IMAGE_NAME)

test:
	@echo "=== Checking extensions for $(IMAGE_NAME):fpm-$(PHP_VERSION) ==="
	@docker run --rm $(IMAGE_NAME):fpm-$(PHP_VERSION) php -m
	@echo "=== Checking wkhtmltopdf ==="
	@docker run --rm $(IMAGE_NAME):fpm-$(PHP_VERSION) wkhtmltopdf --version
	@echo "=== Checking merge2pdf ==="
	@docker run --rm $(IMAGE_NAME):fpm-$(PHP_VERSION) merge2pdf -h || true
	@echo "=== Checking composer ==="
	@docker run --rm $(IMAGE_NAME):fpm-$(PHP_VERSION) composer --version
