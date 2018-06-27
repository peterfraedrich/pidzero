package main

import (
	"flag"
	"os"

	"github.com/Sirupsen/logrus"
)

var c Config
var l = logrus.New()

func main() {
	logq := make(chan interface{}, c.Pidzero.BufferSize)
	quit := make(chan *Daemon)

	pzlogger := LogRoutine{
		q:   logq,
		log: l,
	}
	go pzlogger.start()

	var daemonList []Daemon
	for _, i := range c.Daemons {
		d := Daemon{
			Name:        i.Name,
			Command:     i.Command,
			Args:        i.Args,
			Description: i.Description,
			Vital:       i.Vital,
			Env:         i.Env,
			dlog:        i.Log,
			q:           logq,
			quit:        quit,
		}
		daemonList = append(daemonList, d)
		go d.start()
	}

	mw := LogMiddleware{
		r:      l,
		config: c,
	}

	api := API{
		host:          c.API.Host,
		port:          c.API.Port,
		authEnabled:   c.API.Auth.Enabled,
		authKey:       c.API.Auth.Key,
		httpsEnabled:  c.API.HTTPS.Enabled,
		httpsSelfSign: c.API.HTTPS.SelfSign,
		httpsPrivKey:  c.API.HTTPS.PrivateKey,
		httpsPubKey:   c.API.HTTPS.PublicKey,
		logping:       c.API.LogPing,
		accesslog:     c.API.AccessLog,
		q:             logq,
		middleware:    mw,
		mainlogger:    l,
		config:        c,
	}
	go api.start()

	// blocking call to get "quit" signal on channel
	p := <-quit
	if p != nil {
		os.Exit(1)
	}
	os.Exit(0)

}

func init() {
	// Do some setup stuff before starting main()
	ParseArgs()
	ReadConfig()
	SetupLogging()
}

// ParseArgs : parses command line arguments
func ParseArgs() {
	flag.StringVar(&Args.configFile, "config", "config.yaml", "Absolute path to config.yaml")
	flag.Parse()
}

// ReadConfig : reads config from file
func ReadConfig() {
	c.read(Args.configFile)
}

// SetupLogging : sets up logging for the rest of the app
func SetupLogging() {
	l.Out = os.Stdout
	if c.Pidzero.PrettyLogging == false {
		l.Formatter = &logrus.JSONFormatter{}
	} else {
		l.Formatter = &logrus.TextFormatter{
			FullTimestamp: true,
		}
	}
	l.SetLevel(getLogLevel(c.Pidzero.LogLevel))

}
