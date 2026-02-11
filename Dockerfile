FROM golang:1.26.0-alpine AS builder
WORKDIR /app
RUN go clean -modcache
RUN CGO_ENABLED=0 GOOS=linux go install github.com/TwiN/gatus/v5@v5.34.0

# checkov:skip=CKV_DOCKER_2:Scratch image has no shell for HEALTHCHECK; health verified via ALB target group and workflow health check
FROM scratch
COPY --from=builder  /go/bin/gatus /go/bin/gatus
COPY --from=builder  /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY  /app/config/config.yaml /app/config/config.yaml
USER 1000
ENV GATUS_CONFIG_PATH=/app/config/config.yaml
EXPOSE 8080
ENTRYPOINT ["/go/bin/gatus"]
