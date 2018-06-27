package main

import (
	"fmt"
	"io/ioutil"

	yaml "gopkg.in/yaml.v2"
)

// Config : implements a struct for our config.yaml
type Config struct {
	API struct {
		Host string
		Port uint
		Auth struct {
			Enabled bool
			Key     string
		}
		HTTPS struct {
			Enabled    bool
			SelfSign   bool
			PrivateKey string
			PublicKey  string
		}
		AccessLog bool
		LogPing   bool
	}
	Daemons []struct {
		Name        string
		Description string
		Command     string
		Args        []string
		Vital       bool
		Log         bool
		Env         []string
	}
	Pidzero struct {
		BufferSize    uint64
		LogLevel      string
		PrettyLogging bool
	}
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
