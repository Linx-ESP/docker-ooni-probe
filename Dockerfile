# No specific reason for this image. Should probably change it at some point
# Same CVEs as debian because they don't do patches

FROM bitnami/minideb:bookworm
ARG APP_UID=1000 \
    APP_GID=1000

USER root

# Copied from https://ooni.org/install/cli/ubuntu-debian/ 

RUN set -ex; \
    apt update && apt install -y ca-certificates curl \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xb5a08f01796e7f521861b449372d1ff271f2dd50" -o /etc/apt/keyrings/ooni-apt-keyring.asc \
    && chmod a+r /etc/apt/keyrings/ooni-apt-keyring.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/ooni-apt-keyring.asc] https://deb.ooni.org/ unstable main" | tee /etc/apt/sources.list.d/ooniprobe.list \
    && apt update \
    && apt install -y ooniprobe-cli \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Something about openshift not liking fixed UIDs, idk
USER ${APP_UID}:${APP_GID}
ENTRYPOINT [ "/usr/bin/ooniprobe", "run", "unattended" ]
