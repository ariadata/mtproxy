FROM ariadata/baseimage-s6-overlay-ubuntu-20:v2

LABEL maintainer="AriaData (@ariadata)"

ENV DEBIAN_FRONTEND=noninteractive S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Install Ondrej repos for Ubuntu focal, PHP8.2, composer and selected extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg curl ca-certificates cron iproute2 xxd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Cron: Remove defaults
RUN rm -rf /etc/cron.d/* /etc/cron.daily/* /etc/cron.hourly/* /etc/cron.monthly/* /etc/cron.weekly/*

# Copy over S6 configurations
COPY etc/services.d/ /etc/services.d/

# Copy over cron jobs
COPY /etc/cron.daily/ /etc/cron.daily/

RUN chmod +x /etc/cron.daily/update-proxy

# Copy binaries
COPY /etc/files/mtproto-proxy /usr/bin/mtproto-proxy
COPY /etc/files/start_mtproxy.sh /usr/bin/start_mtproxy.sh
# chmod the binaries
RUN chmod +x /usr/bin/mtproto-proxy /usr/bin/start_mtproxy.sh

# Set the default work directory to our web user
WORKDIR /

# Expose ports
EXPOSE 443

#Configure S6 to drop priveleges
ENTRYPOINT ["/init"]