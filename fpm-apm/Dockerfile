ARG PHP_VERSION=8.2.35
ARG BASE_IMAGE=ferozcse/php-8.2-buster:fpm-${PHP_VERSION}
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.authors="Saiful Islam Feroz <ferozcse@gmail.com>"

ARG ELASTIC_APM_VERSION=1.17.1

RUN set -eux; \
	ARCH="$(dpkg --print-architecture)"; \
	case "$ARCH" in \
		amd64) apm_arch="amd64" ;; \
		arm64) apm_arch="arm64" ;; \
		*) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; \
	esac; \
	curl -sSL "https://github.com/elastic/apm-agent-php/releases/download/v${ELASTIC_APM_VERSION}/apm-agent-php_${ELASTIC_APM_VERSION}_${apm_arch}.deb" -o /tmp/apm-agent-php.deb; \
	dpkg -i /tmp/apm-agent-php.deb; \
	rm -f /tmp/apm-agent-php.deb; \
	php -m | grep -i elastic_apm
