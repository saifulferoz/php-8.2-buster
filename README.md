# php-8.2-buster / php-8.2-debian

Docker images for PHP 8.2 with full extension support, based on the `ronisaha/php-8.1-buster` stack, modern Debian Bookworm, and multi-architecture (`amd64` and `arm64`) support.

> **Note on Debian Base & PHP 8.2 Versions**:
> - Debian Buster (Debian 10) is End-of-Life (EOL). Upstream official PHP Docker images never released PHP 8.2 on Buster; official PHP 8.2 images are based on Debian Bookworm (Debian 12).
> - The latest upstream release of PHP 8.2 is **8.2.35**. These images default to `8.2.35` and can be built immediately for **8.2.36** as soon as the upstream base image is published by passing `--build-arg PHP_VERSION=8.2.36`.

---

## Included Extensions & Tools

All images include:
- **Core / Bundled PHP Extensions**:
  `bcmath`, `curl`, `exif`, `gettext`, `iconv`, `intl`, `json`, `libxml`, `mbstring`, `openssl`, `opcache`, `PDO`, `pdo_mysql`, `pdo_pgsql`, `pgsql`, `SimpleXML`, `soap`, `sockets`, `tokenizer`, `xsl`, `zip`
- **PECL / Third-Party Extensions**:
  `amqp`, `apcu`, `gd`, `igbinary`, `imagick`, `mongodb`, `oci8` (with Oracle Instant Client), `redis`, `yaml`, and `xdebug` (in `dev` and `cli`)
- **System Tools & Binaries**:
  - [wkhtmltopdf 0.12.6.1](https://github.com/wkhtmltopdf/wkhtmltopdf/) with patched QT
  - [merge2pdf](https://github.com/ajaxray/merge2pdf) v1.1.0
  - [Composer](https://getcomposer.org/) (latest multi-stage build)
  - Oracle Instant Client (basiclite & SDK with `ldconfig`)
  - Custom Truetype fonts (SolaimanLipi, Arial Narrow suite, `ttf-mscorefonts-installer`)
- **Standard Configurations**:
  - `opcache-recommended.ini` (CLI enabled)
  - `00-override.ini` (`memory_limit=3504M`, `upload_max_filesize=256M`, `post_max_size=2048M`, `timezone=Asia/Dhaka`, `max_execution_time=300`)
  - `error-logging.ini` (logging to `/dev/stderr`)

---

## Image Variants & Tags

| Tag / Variant | Base Image | Features |
|---|---|---|
| `cli`, `cli-8.2`, `cli-8.2.35` | `php:${PHP_VERSION}-cli-bookworm` | CLI base with Node.js (18.x), npm, and xdebug |
| `fpm`, `fpm-8.2`, `fpm-8.2.35`, `latest` | `php:${PHP_VERSION}-fpm-bookworm` | FPM base with custom `zz-docker.conf` tuning |
| `apache`, `apache-8.2`, `apache-8.2.35` | `php:${PHP_VERSION}-apache-bookworm` | Apache base with `mod_rewrite`, `LimitRequestFieldSize`, DocumentRoot at `/var/www/public` |
| `dev`, `dev-8.2`, `dev-8.2.35` | `php:${PHP_VERSION}-apache-bookworm` | Apache base with `xdebug` enabled |
| `supervisor`, `supervisor-8.2`, `supervisor-8.2.35` | `php:${PHP_VERSION}-cli-bookworm` | CLI base with `supervisord` installed and set as container ENTRYPOINT |

---

## Building the Images

### 1. Build all variants:
```bash
# Using Make (defaults to PHP 8.2.35)
make build

# Build with PHP 8.2.36 (once upstream is published)
make build PHP_VERSION=8.2.36
```

### 2. Build a specific variant:
```bash
make build-fpm
make build-cli
make build-apache
make build-dev
make build-supervisor
```

### 3. Using build.sh directly:
```bash
./build.sh all 8.2.35 ronisaha/php-8.2-buster
./build.sh fpm 8.2.36 ronisaha/php-8.2-buster
```

### 4. Test built images:
```bash
make test
```
