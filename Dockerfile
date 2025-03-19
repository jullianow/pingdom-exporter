FROM golang:1.23 AS builder

ARG VERSION

WORKDIR /app
ADD . .
RUN make build VERSION=$VERSION

FROM alpine:3.21 AS final

RUN apk add --no-cache ca-certificates && update-ca-certificates

WORKDIR /bin/

COPY --from=builder /app/bin/pingdom-exporter .

RUN addgroup prometheus
RUN adduser -S -u 1000 prometheus \
    && chown -R prometheus:prometheus /bin

USER 1000

EXPOSE 9158

ENTRYPOINT ["/bin/pingdom-exporter"]
