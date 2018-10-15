package main

import (
	"fmt"
	"io/ioutil"

	yaml "gopkg.in/yaml.v2"
)

// Config : implements a struct for our config.yaml
type Config struct {
	API struct {
		Host string `yaml:"host"`
		Port uint   `yaml:"port"`
		Auth struct {
			Enabled bool   `yaml:"enabled"`
			Key     string `yaml:"key"`
		}
		HTTPS struct {
			Enabled    bool   `yaml:"enabled"`
			PrivateKey string `yaml:"private_key"`
			PublicKey  string `yaml:"public_key"`
		}
		AccessLog bool `yaml:"accesslog"`
		LogPing   bool `yaml:"logping"`
	}
	Daemons []struct {
		Name        string   `yaml:"name"`
		Description string   `yaml:"description"`
		Command     string   `yaml:"command"`
		Args        []string `yaml:"args"`
		Vital       bool     `yaml:"vital"`
		Log         bool     `yaml:"log"`
		Env         []string `yaml:"env"`
	}
	Pidzero struct {
		BufferSize    uint64 `yaml:"buffersize"`
		LogLevel      string `yaml:"loglevel"`
		PrettyLogging bool   `yaml:"prettylogging"`
	}
}

type https struct {
}

func (c *Config) read(p string) *Config {
	f, err := ioutil.ReadFile(p)
	if err != nil {
		panic(fmt.Sprintf("Unable to read config from %s : %s", p, err))
	}
	err = yaml.Unmarshal(f, c)
	if err != nil {
		panic("Could not unmarshal config.yaml")
	}
	return c
}
