test:
	go build .
	./pidzero

build:
	glide install
	go build .