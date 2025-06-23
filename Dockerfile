FROM bitnami/minideb:bookworm
# switch to root during setup
USER root
# setup your app
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