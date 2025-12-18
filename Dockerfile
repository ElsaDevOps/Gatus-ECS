FROM golang:1.24.4 AS builder
WORKDIR /app
RUN CGO_ENABLED=0 GOOS=linux go install github.com/TwiN/gatus/v5@latest

FROM scratch
COPY --from=builder  /go/bin/gatus /go/bin/gatus
COPY --from=builder  /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY  /app/config/config.yaml /app/config/config.yaml
USER 1000
ENV GATUS_CONFIG_PATH=/app/config/config.yaml
EXPOSE 8080
CMD ["/go/bin/gatus", "/app/config/config.yaml"]
