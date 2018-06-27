package main

import (
	"fmt"
	"os"
	"runtime"

	"github.com/Sirupsen/logrus"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// API : implements a REST API
type API struct {
	host          string
	port          uint
	authEnabled   bool
	authKey       string
	httpsEnabled  bool
	httpsSelfSign bool
	httpsPrivKey  string
	httpsPubKey   string
	logping       bool
	accesslog     bool
	q             chan interface{}
	middleware    LogMiddleware
	mainlogger    *logrus.Logger
	config        Config
}

func (a *API) handle() {

}

func (a *API) start() {
	e := echo.New()
	e.Logger = LogMiddleware{r: a.mainlogger}
	e.Use(middleware.KeyAuth(func(key string, c echo.Context) (bool, error) {
		if a.authEnabled == true {
			return key == a.authKey, nil
		}
		return true, nil
	}))
	e.Use(a.middleware.middlewareHook())
	e.HideBanner = true
	e.HidePort = true

	e.GET("/ping", func(c echo.Context) error {
		p := &Ping{Ping: "ok"}
		return c.JSON(200, p)
	})

	e.GET("/config", func(c echo.Context) error {
		return c.JSON(200, a.config)
	})

	e.GET("/config/api", func(c echo.Context) error {
		return c.JSON(200, a.config.API)
	})

	e.GET("/config/daemons", func(c echo.Context) error {
		return c.JSON(200, a.config.Daemons)
	})

	e.GET("/config/pidzero", func(c echo.Context) error {
		return c.JSON(200, a.config.Pidzero)
	})

	e.GET("/env", func(c echo.Context) error {
		return c.JSON(200, os.Environ())
	})

	e.GET("/stats", func(c echo.Context) error {
		m := runtime.MemStats{}
		runtime.ReadMemStats(&m)
		return c.JSON(200, m)
	})
	hostport := fmt.Sprintf("%s:%v", a.config.API.Host, a.config.API.Port)
	a.mainlogger.Debug(fmt.Sprintf("Starting API on %s", hostport))
	if a.config.API.HTTPS.Enabled == true {
		a.mainlogger.Fatal(e.StartTLS(hostport, a.httpsPubKey, a.httpsPrivKey))
	} else {
		a.mainlogger.Fatal(e.Start(hostport))
	}

}
