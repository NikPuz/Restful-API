FROM rhaps1071/golang-1.14-alpine-git AS build

WORKDIR /build

COPY . .

RUN CGO_ENABLED=0 go build -ldflags "-s -w -extldflags '-static'" -o main .

FROM alpine:3.14.0

WORKDIR /build/app/

COPY --from=build /build/ .

COPY /config .

COPY /db/migrations .

ADD https://github.com/pressly/goose/releases/download/v3.5.3/goose_linux_x86_64 /bin/goose

RUN chmod +x /bin/goose

EXPOSE ${APP_PORT}

CMD goose mysql "${DB_USER}:${DB_PASSWORD}@${DB_SOURCE}/${DB_DATABASE}?parseTime=true" up && /build/app/main