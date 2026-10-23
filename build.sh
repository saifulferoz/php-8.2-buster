#!/usr/bin/env bash
set -euo pipefail

VARIANTS=("fpm" "apache" "cli" "supervisor" "dev" "fpm-apm")
ACTION="${1:-all}"
PHP_VERSION="${2:-8.2.35}"
IMAGE_NAME="${3:-ferozcse/php-8.2-buster}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
PHP_SHORT_VERSION="8.2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

build_and_push_variant() {
    local target="$1"
    echo "=========================================================="
    echo " Building & Pushing multi-arch [${PLATFORMS}]"
    echo " Image: ${IMAGE_NAME}:${target}-${PHP_VERSION}"
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

    local tags=(
        --tag "${IMAGE_NAME}:${target}-${PHP_VERSION}"
        --tag "${IMAGE_NAME}:${target}-${PHP_SHORT_VERSION}"
        --tag "${IMAGE_NAME}:${target}"
    )

    if [ "$target" = "fpm" ]; then
        tags+=(--tag "${IMAGE_NAME}:latest")
    fi

    # Build and push multi-platform images using buildx
    docker buildx build "$target" \
        --file "$target/Dockerfile" \
        --platform "$PLATFORMS" \
        --build-arg PHP_VERSION="$PHP_VERSION" \
        "${tags[@]}" \
        --push

    echo " Successfully built and pushed multi-arch:"
    echo "  - ${IMAGE_NAME}:${target}-${PHP_VERSION}"
    echo "  - ${IMAGE_NAME}:${target}-${PHP_SHORT_VERSION}"
    echo "  - ${IMAGE_NAME}:${target}"
    if [ "$target" = "fpm" ]; then
        echo "  - ${IMAGE_NAME}:latest"
    fi
}

case "$ACTION" in
    all|push-all)
        for v in "${VARIANTS[@]}"; do
            build_and_push_variant "$v"
        done
        ;;
    push-variant)
        target_variant="${2:-fpm}"
        PHP_VERSION="${3:-8.2.35}"
        IMAGE_NAME="${4:-ferozcse/php-8.2-buster}"
        build_and_push_variant "$target_variant"
        ;;
    *)
        # Single variant build & push
        build_and_push_variant "$ACTION"
        ;;
esac

echo "=========================================================="
echo "Done!"
echo "=========================================================="
