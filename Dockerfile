# syntax=docker/dockerfile:1

# Trellis already contains its frontend, API, and production runtime. This
# zero-overhead wrapper adds deployment metadata without adding another layer.
ARG TRELLIS_IMAGE=ghcr.io/lpierpoint/trellis:latest
FROM ${TRELLIS_IMAGE}

LABEL org.opencontainers.image.title="Trellis for Bunny Magic Containers" \
      org.opencontainers.image.description="Jellyfin-compatible server for Stremio addons"

ENV HOST=0.0.0.0 \
    PORT=8477

EXPOSE 8477
VOLUME ["/config"]
STOPSIGNAL SIGTERM
