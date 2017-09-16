ARG arch
FROM multiarch/debian-debootstrap:${arch}-stretch

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install pdns-server pdns-backend-remote git wget curl tar 

ARG arch
ARG etcd_version=v3.2.6
ARG go_version=1.9
ARG itdns_version=2.1

#Install golang
RUN wget -O -  "https://golang.org/dl/go${go_version}.linux-${arch}.tar.gz" | tar xzC /usr/local
ENV GOPATH /go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# Install Etcd
RUN wget -O - https://github.com/coreos/etcd/releases/download/${etcd_version}/${etcd_version}.tar.gz | tar -xz &&\
    cd etcd-* &&\
    ./build && \
    mv ./bin/* /usr/bin/ &&\
rm -fr etcd-* 

# Install ITDNS
RUN case "${ARCH}" in                                                                                 \
    armv7l|armhf|arm)                                                                                 \
      curl -Ls https://github.com/innovate-technologies/ITDNS/releases/download/${itdns_version}/ITDNS-linux-arm > /usr/bin/ITDNS && \
      chmod +x /usr/bin/ITDNS                                                                     \
      ;;                                                                                              \
    amd64|x86_64)                                                                                     \
      curl -Ls https://github.com/innovate-technologies/ITDNS/releases/download/${itdns_version}/ITDNS-linux-amd64 > /usr/bin/ITDNS && \
      chmod +x /usr/bin/ITDNS                                                                     \
      ;;                                                                                              \
    arm64|aarch64)                                                                                    \
      curl -Ls https://github.com/innovate-technologies/ITDNS/releases/download/${itdns_version}/ITDNS-linux-arm64 > /usr/bin/ITDNS && \
      chmod +x /usr/bin/ITDNS                                                                     \
      ;;                                                                                              \
    *)                                                                                                \
      echo "Unhandled architecture: ${ARCH}."; exit 1;                                                \
      ;;                                                                                              \
esac 

# Configure
COPY ./pdns.conf /etc/powerdns/pdns.conf

# Set the etcd
RUN mkdir -p /etc/ssl/etcd/
ENV ITDNS_ETCD3_CA /etc/ssl/etcd/ca.pem
ENV ITDNS_ETCD3_ENTRYPOINTS https://localhost:2379


EXPOSE  53
EXPOSE  53/udp

# Copy start

COPY ./start.sh /opt/itdns/start,sh

CMD /opt/itdns/start,sh