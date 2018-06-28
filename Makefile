test:
	go build .
	./pidzero

build:
	glide install
	go build .

pidzero-docker:
	glide install
	glide up
	CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags '-s' -o pidzero $GOPATH/src/hexapp.net/pidzero/main.go
	cat << EOF > docker/Dockerfile.scratch
	FROM scratch
	ADD pidzero /etc/pidzero/
	ADD config.yaml /etc/pidzero/
	ADD /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
	CMD /etc/pidzero/pidzero -configFile /etc/pidzero/pidzero
	EOF
	cat << EOF > docker/Dockerfile.ubuntu
	FROM ubuntu:18.04
	ADD pidzero /etc/pidzero/
	ADD config.yaml /etc/pidzero/
	CMD /etc/pidzero/pidzero -configFile /etc/pidzero/pidzero
	EOF
	cat << EOF > docker/Dockerfile.alpine
	FROM alpine:latest
	ADD pidzero /etc/pidzero/
	ADD config.yaml /etc/pidzero/
	CMD /etc/pidzero/pidzero -configFile /etc/pidzero/pidzero
	EOF
	docker build --compress --squash --tag hexapp/pidzero:latest --tag hexapp/pidzero:$(cat .semver)-scratch -f docker/Dockerfile.scratch
	docker build --compress --squash --tag hexapp/pidzero:$(cat .semver)-ubuntu1804 -f docker/Dockerfile.ubuntu
	docker build --compress --squash --tag hexapp/pidzero:$(cat .semver)-alpine -f docker/Dockerfile.alpine
