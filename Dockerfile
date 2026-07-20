# Base docker image
FROM debian:trixie-slim

LABEL maintainer="v0l"

# Install dependencies to add Tor's repository.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gpg \
    ca-certificates \
    libcap2-bin \
    && rm -rf /var/lib/apt/lists/*

# See: <https://support.torproject.org/apt/>
RUN curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc \
    | gpg --dearmor -o /usr/share/keyrings/tor-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org trixie main" \
    > /etc/apt/sources.list.d/tor.list

# Install remaining dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tor \
    tor-geoipdb \
    obfs4proxy \
    && rm -rf /var/lib/apt/lists/*

# Allow obfs4proxy to bind to ports < 1024.
RUN setcap cap_net_bind_service=+ep /usr/bin/obfs4proxy

COPY torrc /etc/tor/torrc
RUN mkdir -p /var/log/tor /etc/torrc.d \
    && chown -R debian-tor:debian-tor /etc/tor /var/log/tor /etc/torrc.d

# ORPort and obfs4 pluggable-transport port.
EXPOSE 9001 9002

USER debian-tor
ENTRYPOINT [ "tor" ]
