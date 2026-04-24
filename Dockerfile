# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
  # GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000

  # FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
#  FROM 11notes/distroless:dnslookup AS distroless-dnslookup
  FROM 11notes/util:bin AS util-bin

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝

  FROM golang:1.24-alpine AS build
  COPY --from=util-bin / /
  ARG APP_VERSION=3.29 \
      BUILD_ROOT \
      BUILD_BIN \
      TARGETARCH=amd64 \
      TARGETPLATFORM \
      TARGETVARIANT \
      BUILD_DIR=/go/probe-cli \
      CGO_ENABLED=0

  ENV BUILD_BIN=${BUILD_DIR}/probe-cli/CLI/ooniprobe-linux-${TARGETARCH}


  RUN set -ex; \
    apk --update --no-cache add \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      g++ \
      git \
      npm \
      gpg \
      zip \
      tar \
      yarn;

  RUN set -ex; \
    mkdir ${BUILD_DIR}; \
    cd ${BUILD_DIR}; \
    git clone https://github.com/ooni/probe-cli.git -b release/${APP_VERSION}; \
    cd probe-cli; \
    go run ./internal/cmd/buildtool linux static

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};
  # compress and copy. https://github.com/11notes/docker-util/blob/master/rootfs/usr/local/bin/.eleven/distroless

# :: FILE SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT
  USER root

  RUN set -ex; \
    mkdir -p /distroless${APP_ROOT}/etc; \
    mkdir -p /distroless${APP_ROOT}/var; \
    mkdir -p /distroless${APP_ROOT}/run; \
    mkdir -p /distroless${APP_ROOT}/tmp; \
    mkdir -p /distroless/.ooniprobe   
# ooniprobe will exit it doesn't have tmp permissions, permissions set later

  RUN set -ex; \
    echo '{ \
  "_version": 1, \
  "_informed_consent": true, \
  "sharing": { \
    "upload_results": true \
  }, \
  "nettests": { \
    "websites_max_runtime": 0 \
  }, \
  "advanced": {} \
}' >> /distroless/.ooniprobe/config.json

# This is an awful way to do this, should use ENV variables on the compose. 
# The point is setting "_informed_consent" to "true" so it can start without editing a file.
# Not editing a file is for running without bind mounts, and just named volumes.
# At some point I might try do it from the compose, but for now, nope. 


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
      APP_NAME=${APP_NAME} \
      APP_VERSION=${APP_VERSION} \
      APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless / /
#    COPY --from=distroless-dnslookup / /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /


# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
ENTRYPOINT [ "/usr/local/bin/ooniprobe-linux-amd64", "run", "unattended" ]
