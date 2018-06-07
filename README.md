# PIDZERO

`pidzero` is a lightweight process host designed exclusively for Docker/LXC containers. `pidzero` lets you run multiple process inside a container safely while avoiding "dead container" situations by failing fast.

### How it works
`pidzero` is a small binary that takes daemon definitions in a file `daemons.json` and then executes those process in a sub-process, much like how `systemd` or `supervisord` work. Unlike those and other init systems, `pidzero` will fail if any of the daemons marked `vital` exit for any reason. This ensures that your container will never be "alive" unless it is 100% healthy. Additionally, `pidzero` will output any daemon output (stdout and stderr) to a log file, its own stdout (to be captured by Docker or another logging system), or both. Output can be either in a custom `map` format, or JSON, where the process output is set to the `line` field.


### Usage

`pidzero` is designed to be stared by the container. For Docker, simply set your `ENTRYPOINT` to `/<path>/pidzero` and it will do the rest.

```Dockerfile
# SAMPLE DOCKER FILE
FROM ubuntu:18.04
COPY pidzero daemons.json config.json /opt/
ENTRYPOINT /opt/pidzero
```

`pidzero` should be placed in a directory alongside its configuration files, as such:
```
<directory>
  |--- pidzero
  |--- daemons.json
  |--- config.json
  |--- ...
```

### Configuration

`pidzero` uses `config.json` to store its configuration. This file should be placed in the same folder as `pidzero`.

```shell
{
    "log": {
        "json": true,
        "file_path": "pidzero.log",
        "log_to_file": true,
        "log_to_stdout": true
    }
}

- json           => enable JSON logging. set to `false` for map
- file_path      => path for the logfile (if enabled)
- log_to_file    => enable/disable file logging
- log_to_stdout  => enable/disable logging to stdout
```

### Daemon Configuration

To configure a daemon for `pidzero` to run, you must specify its definition in `daemons.json` (which should be placed alongside `pidzero`). A sample `daemons.json` looks something like this:
```shell
[
    {
        "name" : "some_process",
        "command" : "/command/to/run -arg1 -arg2",
        "comments" : "this is a demo process, please don't try to run this for real",
        "vital" : true,
        "environment" : [
            "SOME_ENV_VAR=some_value",
            "SOME_OTHER_VAR=another_value"
        ]
    },
    {
        "name" : "foobar",
        "command" : "/foo/bar",
        "comments" : "",
        "vital" : false,
        "environment" : []
    }
]

- name        => a friendly name to give the process
- command     => the command to run with args and such
- comments    => any human-friendly comments to provide, these are ignored by the process host
- vital       => marks the process as vital, if it is vital and it exits the process host will throw and error and quit
- environment => linux-style environment variable declaration, will be appended to the beginning of <command> before running

==> This JSON object _must_ be an array (list), otherwise everything will break.
```

### Logging

By default all logs are captured and sent to `pidzero`'s `stdout` in JSON format. This can then be picked up by something like `fluentd` or `logstash` and sent to a log aggregation server. Optionally, `pidzero` can log to a file in the container if you're using a mounted volume for logging.

The log format is either JSON or a map, and can be toggled with the `json:Bool` option in `config.json`.


### Best Practices

The use of `pidzero` is contrary to Docker's stated best-practice of running a single process in each container. However, sometimes this is impractical due to things like logging, monitoring, or other processes that need to run next to your application (for example, running Hashicorp's Consul for service discovery).

It is **not recommended** to use `pidzero` to run more than one "main" applications in a container due to resource usage and this being an even more flagrant violation of Docker best practices. Additionally, from an architectural point of view, you don't want the failure of a single app instance to affect the availability of another, which would be the case if you ran two instances of an app in the same container. Essentially `pidzero` allows you to run a sidecar in your container.

### Other Software
What about `supervisord`, `runit`, `sysinit`, `systemd`, or `<insert init system here>`?

None of these were designed to be run in a container and their design shows it. `runit` relies on a convoluted (and frankly confusing) folder structure, `sysinit` and `systemd` were designed for full Linux installs and are often not even included in containers due to security or compatibility issues, and `supervisord` is not designed to be "PID 1" and is too heavy for a container.

***

#### Roadmap
* REST API to `pidzero` for healthcheck and daemon information
* TCP API for healthcheck and daemon information
* Additional log formats and handlers
* CLI tool (?)

***

`pidzero` is written in Haxe and designed to be compiled to C++
