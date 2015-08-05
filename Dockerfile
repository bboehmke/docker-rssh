FROM debian:jessie
MAINTAINER Benjamin Böhmke

# Install OpenSSH and rssh
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server rsync rssh && \
    rm -rf /var/lib/apt/lists/*

# add sshd run dir
RUN mkdir -p /var/run/sshd

# copy configuration
COPY sshd_config /etc/ssh/sshd_config

# add entry script
COPY entrypoint.sh /bin/entrypoint

EXPOSE 22
ENTRYPOINT ["entrypoint"]