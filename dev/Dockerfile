ARG PHP_VERSION=8.2.35
FROM php:${PHP_VERSION}-apache-bookworm

LABEL org.opencontainers.image.authors="Saiful Islam Feroz <ferozcse@gmail.com>"

ENV APACHE_DOCUMENT_ROOT /var/www/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

ENV LD_LIBRARY_PATH=/usr/lib/instantclient

#install exetentions and dependencies
RUN set -eux; \
	\
	if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
		sed -i 's/Components: main/Components: main contrib/' /etc/apt/sources.list.d/debian.sources; \
	elif [ -f /etc/apt/sources.list ]; then \
		sed -i'.bak' 's/$/ contrib/' /etc/apt/sources.list; \
	fi; \
	apt-get update && apt-get -y upgrade; \
	apt-get install -y wget; \
	echo "timeout = 15" >> /etc/wgetrc; \
	echo "tries = 2" >> /etc/wgetrc; \
	apt-get install -y libaio1 unzip \
		libicu-dev \
		libzip-dev \
		libyaml-dev \
		gettext graphviz \
		libmagickwand-dev \
		librabbitmq-dev \
		libpq-dev \
		imagemagick \
		libxslt1-dev \
		\
		fontconfig \
		libfreetype6 \
		libjpeg62-turbo \
		libpng16-16 \
		libx11-6 \
		libxcb1 \
		libxext6 \
		libxrender1 \
		xfonts-75dpi \
		xfonts-base \
		ttf-mscorefonts-installer \
	; \
	\
	pecl install apcu; \
	pecl install yaml; \
	pecl install igbinary; \
	pecl install mongodb; \
	docker-php-ext-enable apcu yaml igbinary mongodb; \
	docker-php-ext-install -j$(nproc) iconv; \
	docker-php-ext-configure intl; \
	docker-php-ext-install -j$(nproc) intl; \
	docker-php-ext-install -j$(nproc) \
		exif \
		bcmath \
		xsl \
		gettext \
		opcache \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		pgsql \
		soap \
		zip \
		sockets; \
	echo 'yes,yes' | pecl install redis; \
	docker-php-ext-enable redis; \
	cd /tmp; \
	ARCH="$(dpkg --print-architecture)"; \
	case "$ARCH" in \
		amd64) \
			oracle_arch=linuxx64; \
			wkhtml_pkg="wkhtmltox_0.12.6.1-3.bookworm_amd64.deb"; \
			merge2pdf_bin="merge2pdf_linux-amd64.OS"; \
			;; \
		arm64) \
			oracle_arch=linux-arm64; \
			wkhtml_pkg="wkhtmltox_0.12.6.1-3.bookworm_arm64.deb"; \
			merge2pdf_bin="merge2pdf_linux-arm64.architecture"; \
			;; \
		*) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; \
	esac; \
	curl -L -O "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/${wkhtml_pkg}"; \
	dpkg -i "${wkhtml_pkg}"; \
	rm -rf "${wkhtml_pkg}"; \
	wget -O instantclient-basiclite.zip "https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-${oracle_arch}.zip"; \
	wget -O instantclient-sdk.zip "https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-${oracle_arch}.zip"; \
	unzip instantclient-basiclite.zip; \
	unzip -o instantclient-sdk.zip; \
	rm -f instantclient-basiclite.zip instantclient-sdk.zip; \
	mv instantclient*/ /usr/lib/instantclient; \
	cd /usr/lib/instantclient; \
	rm -f *jdbc* *occi* *mysql* *README *jar uidrvci genezi adrci; \
	echo /usr/lib/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf; \
	ldconfig; \
	echo 'instantclient,/usr/lib/instantclient' | pecl install oci8; \
	pecl install xdebug; \
	docker-php-ext-enable oci8 xdebug; \
	curl -L https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions > /usr/local/bin/install-php-extensions; \
	chmod +x /usr/local/bin/install-php-extensions; \
	install-php-extensions gd imagick amqp; \
	rm -f /usr/local/bin/install-php-extensions; \
	\
	docker-php-source delete; \
	apt-get remove -y g++ wget; \
	apt-get autoremove --purge -y && apt-get autoclean -y && apt-get clean -y; \
	rm -rf /var/lib/apt/lists/*; \
	rm -rf /tmp/* /var/tmp/*;

## Set php configuration
RUN { \
            echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini ; \
    { \
            echo 'date.timezone=Asia/Dhaka'; \
            echo 'upload_max_filesize=256M'; \
            echo 'post_max_size=2048M'; \
            echo 'max_input_vars=10000'; \
            echo 'memory_limit=3504M'; \
            echo 'expose_php = off'; \
            echo 'max_execution_time = 300'; \
    } > /usr/local/etc/php/conf.d/00-override.ini ; \
    { \
        echo 'error_reporting = 4339'; \
        echo 'display_errors = Off'; \
        echo 'display_startup_errors = Off'; \
        echo 'log_errors = On'; \
        echo 'error_log = /dev/stderr'; \
        echo 'log_errors_max_len = 1024'; \
        echo 'ignore_repeated_errors = On'; \
        echo 'ignore_repeated_source = Off'; \
        echo 'html_errors = Off'; \
    } > /usr/local/etc/php/conf.d/error-logging.ini

RUN echo 'LimitRequestFieldSize 5242880' >> /etc/apache2/apache2.conf

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN a2enmod rewrite

RUN set -eux; \
	ARCH="$(dpkg --print-architecture)"; \
	case "$ARCH" in \
		amd64) merge2pdf_bin="merge2pdf_linux-amd64.OS" ;; \
		arm64) merge2pdf_bin="merge2pdf_linux-arm64.architecture" ;; \
		*) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; \
	esac; \
	curl -L "https://github.com/ajaxray/merge2pdf/releases/download/v1.1.0/${merge2pdf_bin}" -o /usr/local/bin/merge2pdf; \
	chmod +x /usr/local/bin/merge2pdf
## Copy Custom Fonts
COPY fonts /usr/share/fonts/truetype
RUN fc-cache -f -v
