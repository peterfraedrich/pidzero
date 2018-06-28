test:
	go build .
	./pidzero

build:
	glide install
	go build .

pidzero-docker:
	#glide install
	#glide up
	#CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags '-w -extldflags "-static"' -o pidzero *.go
	#CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags '-s' 
	./docker/make-dockerfiles.sh
	cp /etc/ssl/certs/ca-certificates.crt .
	cp -f docker/Dockerfile.scratch ./Dockerfile 
	docker build --compress --squash --force-rm --tag hexapp/pidzero:latest --tag hexapp/pidzero:$(shell cat .semver)-scratch .
	cp -f docker/Dockerfile.ubuntu ./Dockerfile 
	docker build --compress --squash --force-rm --tag hexapp/pidzero:$(shell cat .semver)-ubuntu1804 .
	cp -f docker/Dockerfile.alpine ./Dockerfile 
	docker build --compress --squash --force-rm --tag hexapp/pidzero:$(shell cat .semver)-alpine .
	rm -f Dockerfile ca-certificates.crt
	docker images | grep hexapp