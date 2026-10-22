#!/usr/bin/env bash
set -euo pipefail

VARIANTS=("apache" "cli" "fpm" "supervisor" "dev")
ACTION="${1:-all}"
PHP_VERSION="${2:-8.2.35}"
IMAGE_NAME="${3:-ferozcse/php-8.2-buster}"
PHP_SHORT_VERSION="8.2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

build_variant() {
    local target="$1"
    echo "=========================================================="
    echo " Building ${IMAGE_NAME}:${target}-${PHP_VERSION}"
    echo " Base image: php:${PHP_VERSION}-${target}-bookworm"
    echo "=========================================================="

    if [ ! -d "$target" ]; then
        echo "Error: Directory '$target' does not exist." >&2
        exit 1
    fi

    # Ensure fonts directory is present in the build context
    if [ ! -d "$target/fonts" ] && [ -d "fonts" ]; then
        cp -r fonts "$target/"
    fi

    # Build image
    docker build "$target" \
        --file "$target/Dockerfile" \
        --build-arg PHP_VERSION="$PHP_VERSION" \
        --tag "${IMAGE_NAME}:${target}-${PHP_VERSION}" \
        --tag "${IMAGE_NAME}:${target}-${PHP_SHORT_VERSION}" \
        --tag "${IMAGE_NAME}:${target}"

    # Also tag as latest if it is fpm
    if [ "$target" = "fpm" ]; then
        docker tag "${IMAGE_NAME}:${target}-${PHP_VERSION}" "${IMAGE_NAME}:latest"
    fi

    echo " Successfully built and tagged:"
    echo "  - ${IMAGE_NAME}:${target}-${PHP_VERSION}"
    echo "  - ${IMAGE_NAME}:${target}-${PHP_SHORT_VERSION}"
    echo "  - ${IMAGE_NAME}:${target}"
    if [ "$target" = "fpm" ]; then
        echo "  - ${IMAGE_NAME}:latest"
    fi
}

push_variant() {
    local target="$1"
    echo "=========================================================="
    echo " Pushing ${IMAGE_NAME} [${target}] to Docker Hub"
    echo "=========================================================="
    docker push "${IMAGE_NAME}:${target}-${PHP_VERSION}"
    docker push "${IMAGE_NAME}:${target}-${PHP_SHORT_VERSION}"
    docker push "${IMAGE_NAME}:${target}"
    if [ "$target" = "fpm" ]; then
        docker push "${IMAGE_NAME}:latest"
    fi
    echo " Successfully pushed ${target} tags."
}

case "$ACTION" in
    all)
        for v in "${VARIANTS[@]}"; do
            build_variant "$v"
        done
        ;;
    push-all)
        for v in "${VARIANTS[@]}"; do
            push_variant "$v"
        done
        ;;
    push-variant)
        target_variant="${2:-fpm}"
        PHP_VERSION="${3:-8.2.35}"
        IMAGE_NAME="${4:-ferozcse/php-8.2-buster}"
        push_variant "$target_variant"
        ;;
    *)
        # Single variant build
        build_variant "$ACTION"
        ;;
esac

echo "=========================================================="
echo "Done!"
echo "=========================================================="
