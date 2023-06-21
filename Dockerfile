# build executable binary
FROM golang:1.19.0-alpine as builder

ENV CGO_ENABLED 0
ENV GOOS "linux"
ENV GOARCH "amd64"

WORKDIR /build

COPY . .
RUN apk add --no-cache ca-certificates git tzdata && go mod tidy

RUN go build -ldflags "-s -w -extldflags '-static'" -installsuffix cgo -o /bin/api_app main.go

# Use alpine image as runtime
FROM alpine:3.16 as release

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /bin/api_app /bin/api_app

# Command to run 
ENTRYPOINT ["/bin/api_app"]