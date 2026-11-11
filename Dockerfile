# Multi-stage: official xray image has no shell, so copy the binary onto Alpine (with shell)
FROM ghcr.io/xtls/xray-core:latest AS upstream
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata nginx
COPY --from=upstream /usr/local/bin/xray /usr/local/bin/xray
RUN mkdir -p /etc/xray
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Platform injects PORT; UUID and WS_PATH come from platform env vars (never baked into the image)
ENTRYPOINT ["/entrypoint.sh"]
