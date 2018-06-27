# PIDZERO
![zero](doc/pidzero_logo_framed_transp-01.png)

[![pipeline status](https://gitlab.com/hexapp.net/pidzero/badges/master/pipeline.svg)](https://gitlab.com/hexapp.net/pidzero/commits/master)

**pidzero** is a lightweight process host designed exclusively for Docker/LXC containers. **pidzero** lets you run multiple process inside a container safely while avoiding "dead container" situations by failing fast.

### How it works
**pidzero** is a small (~10MB) binary that takes daemon definitions in a file `config.yaml` and then executes those process in a sub-process, much like how `systemd` or `supervisord` work. Unlike those and other init systems, **pidzero** will fail if any of the daemons marked `vital` exit for any reason. This ensures that your container will never be "alive" unless it is 100% healthy. Additionally, **pidzero** will output any daemon output (stdout and stderr) to a log file, its own stdout (to be captured by Docker or another logging system), or both. Output can be either in a "pretty" console output or JSON for easy capture by fluentd, logstash, or another log shipper.

### Quickstart
Pull the latest **pidzero** image from Docker Hub, copy your app and `config.yaml` with your app setup in it to the container, build and run:
```shell
$> docker pull hexapp/pidzero:latest
cat << EOF > Dockerfile
FROM hexapp/pidzero:latest
COPY myapp /some/path/myapp
COPY config.yaml /etc/pidzero/daemons.json
ENTRYPOINT /etc/pidzero/pidzero --configFile $CONFIGPATH
EOF
$> docker build -t myapp:latest .
$> docker run -d myapp:latest
```

### Usage

**pidzero** is designed to be stared by the container. For Docker, simply set your `ENTRYPOINT` to `/<path>/pidzero` and it will do the rest.

```Dockerfile
# SAMPLE DOCKER FILE
FROM ubuntu:18.04
ENV CONFIGPATH=/etc/pidzero/config.json DAEMONPATH=/etc/pidzero/daemons.json
RUN mkdir -p /etc/pidzero
COPY config.yaml pidzero /etc/pidzero/
RUN chmod +x /etc/pidzero/pidzero
ENTRYPOINT /etc/pidzero/pidzero --configFile $CONFIGPATH
```

**pidzero** looks for configuration in the path passed by the `--configFile` flag, or in its local directory by default.
```
Available arguments are:
--configFile [path]      => absolute path of config.yaml

```

### Configuration

**pidzero** uses `config.yaml` to store its configuration. This file should be placed in the same folder as **pidzero**.

Please see the comments in `config.yaml` for config file usage and spec.

### Logging

By default all logs are captured and sent to **pidzero**'s `stdout`. This can then be picked up by something like `fluentd` or `logstash` and sent to a log aggregation server.

The log format is either JSON or pretty text, and can be toggled with the `pidzero.prettylogging` option in `config.yaml`.

### API

**pidzero** comes with a built-in REST API that can be leveraged for monitoring and information gathering. Authentication (optional) is done through bearer tokens, which can be set in `config.yaml`. The API also supports HTTPS when supplied with a certificate and key. 

#### API Routes
```
/ping               => returns a JSON object {"ping" : "ok"}, useful for healthchecks as the API 
                       will not respond if any vital daemons have exited
/config             => return a JSON representation of config.yaml
/config/api         => return API configuration
/config/daemons     => return daemon configuration
/config/pidzero     => return general configuration
/env                => return a list of environment variables present in the container/host where 
                       pidzero is running
/stats              => return memory stats for pidzero
```



### Best Practices

The use of **pidzero** is contrary to Docker's stated best-practice of running a single process in each container. However, sometimes this is impractical due to things like logging, monitoring, or other processes that need to run next to your application (for example, running Hashicorp's Consul for service discovery).

It is **not recommended** to use **pidzero** to run more than one "main" applications in a container due to resource usage and this being an even more flagrant violation of Docker best practices. Additionally, from an architectural point of view, you don't want the failure of a single app instance to affect the availability of another, which would be the case if you ran two instances of an app in the same container. Essentially **pidzero** allows you to run a sidecar in your container.

### Other Software
What about `supervisord`, `runit`, `sysinit`, `systemd`, or `<insert init system here>`?

None of these were designed to be run in a container and their design shows it. `runit` relies on a convoluted (and frankly confusing) folder structure, `sysinit` and `systemd` were designed for full Linux installs and are often not even included in containers due to security or compatibility issues, and `supervisord` is not designed to be "PID 1" and is too heavy for a container.

## Get Pidzero
#### Docker
Pull our Docker images from [Docker Hub](https://hub.docker.com/r/hexapp/pidzero): `hexapp/pidzero`
Tags:
* latest, ubuntu-18.04
* alpine-3.7


#### Building From Source
To build from source, first clone the **pidzero** repo, then run the following:
```shell
$> cd pidzero
$> glide install
$> go build .
```

***

#### Roadmap
- [ ] TCP API for healthcheck and daemon information
- [ ] Additional log formats and handlers
- [ ] CLI tool (?)

***

**pidzero** is written in Go.

![gopher](doc/gofer.png)
