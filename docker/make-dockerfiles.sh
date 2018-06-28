cat << EOF > docker/Dockerfile.scratch
FROM scratch
ADD pidzero /etc/pidzero/
ADD config.yaml /etc/pidzero/
ADD ca-certificates.crt /etc/ssl/certs/
CMD /etc/pidzero/pidzero -config /etc/pidzero/config.yaml
EOF

cat << EOF > docker/Dockerfile.ubuntu
FROM ubuntu:18.04
ADD pidzero /etc/pidzero/
ADD config.yaml /etc/pidzero/
CMD /etc/pidzero/pidzero -config /etc/pidzero/config.yaml
EOF

cat << EOF > docker/Dockerfile.alpine
FROM alpine:latest
ADD pidzero /etc/pidzero/
ADD config.yaml /etc/pidzero/
CMD /etc/pidzero/pidzero -config /etc/pidzero/config.yaml
EOF