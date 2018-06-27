package main

import (
	"io"
	"strconv"
	"strings"
	"time"

	"github.com/Sirupsen/logrus"
	"github.com/labstack/echo"
	"github.com/labstack/gommon/log"
)

// LogRoutine : implements a centralize log endpoint
type LogRoutine struct {
	q   chan interface{}
	log *logrus.Logger
}

func (l *LogRoutine) start() {
	for {
		m, open := <-l.q
		if open == false {
			panic("logging queue has been closed!")
		}
		switch m.(type) {
		case *APILog:
			t := m.(*APILog)
			e := l.log.WithFields(logrus.Fields{
				"uri":    t.uri,
				"method": t.method,
				"status": t.status,
				"type":   t.msgtype,
			})
			l.Write(t.level, e, t.msg)
		case *DaemonLog:
			t := m.(*DaemonLog)
			e := l.log.WithFields(logrus.Fields{
				"type":    "daemon",
				"command": t.command,
				"args":    strings.Join(t.args, " "),
				"vital":   t.vital,
				"env":     strings.Join(t.env, "; "),
				"pid":     t.pid,
			})
			l.Write(t.level, e, t.msg)
		case *ProcessLog:
			t := m.(*ProcessLog)
			e := l.log.WithFields(logrus.Fields{
				"daemon": t.daemon,
				"pipe":   t.pipe,
				"type":   t.msgtype,
			})
			l.Write(t.level, e, t.msg)
		case *AppLog:
			t := m.(*AppLog)
			e := l.log.WithFields(logrus.Fields{
				"event": t.event,
				"type":  t.msgtype,
			})
			l.Write(t.level, e, t.msg)
		}
		time.Sleep(1 * time.Microsecond)
	}
}

func (l *LogRoutine) Write(v string, e *logrus.Entry, m string) {
	funcs := map[string]func(...interface{}){
		"debug": e.Debug,
		"info":  e.Info,
		"warn":  e.Warn,
		"error": e.Error,
		"panic": e.Panic,
	}
	fn, _ := funcs[v]
	fn(m)
}

// LogMiddleware -- echo middleware for logrus
type LogMiddleware struct {
	*logrus.Logger
	r      *logrus.Logger
	config Config
}

func (l LogMiddleware) echoMiddleware(c echo.Context, next echo.HandlerFunc) error {

	req := c.Request()
	res := c.Response()
	start := time.Now()
	if err := next(c); err != nil {
		c.Error(err)
	}
	stop := time.Now()
	p := req.URL.Path
	if p == "" {
		p = "/"
	}
	bytesIn := req.Header.Get(echo.HeaderContentLength)
	if bytesIn == "" {
		bytesIn = "0"
	}
	if c.Path() == "/ping" && l.config.API.LogPing == false || l.config.API.AccessLog == false {
		return nil
	}
	l.r.WithFields(logrus.Fields{
		"time_rfc3339":  time.Now().Format(time.RFC3339),
		"remote_ip":     c.RealIP(),
		"host":          req.Host,
		"uri":           req.RequestURI,
		"method":        req.Method,
		"path":          p,
		"referer":       req.Referer(),
		"user_agent":    req.UserAgent(),
		"status":        res.Status,
		"latency":       strconv.FormatInt(stop.Sub(start).Nanoseconds()/1000, 10),
		"latency_human": stop.Sub(start).String(),
		"bytes_in":      bytesIn,
		"bytes_out":     strconv.FormatInt(res.Size, 10),
	}).Info("API access request")

	return nil
}

func (l LogMiddleware) logger(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		return l.echoMiddleware(c, next)
	}
}

func (l LogMiddleware) middlewareHook() echo.MiddlewareFunc {
	return l.logger
}

// Printj mw
func (l LogMiddleware) Printj(j log.JSON) {
	logrus.WithFields(logrus.Fields(j)).Print()
}

// Debugj mw
func (l LogMiddleware) Debugj(j log.JSON) {
	logrus.WithFields(logrus.Fields(j)).Debug()
}

// Infoj mw
func (l LogMiddleware) Infoj(j log.JSON) {
	logrus.WithFields(logrus.Fields(j)).Info()
}

// Warnj mw
func (l LogMiddleware) Warnj(j log.JSON) {
	logrus.WithFields(logrus.Fields(j)).Warn()
}

// Errorj mw
func (l LogMiddleware) Errorj(j log.JSON) {
	logrus.WithFields(logrus.Fields(j)).Error()
}

// Fatalj mw
func (l LogMiddleware) Fatalj(j log.JSON) {
	logrus.WithFields(logrus.Fields(j)).Fatal()
}

// Panicj mw
func (l LogMiddleware) Panicj(j log.JSON) {
	logrus.WithFields(logrus.Fields(j)).Panic()
}

// Level middleware
func (l LogMiddleware) Level() log.Lvl {
	switch l.r.Level {
	case logrus.DebugLevel:
		return log.DEBUG
	case logrus.WarnLevel:
		return log.WARN
	case logrus.ErrorLevel:
		return log.ERROR
	case logrus.InfoLevel:
		return log.INFO
	default:
		l.r.Panic("Invalid level")
	}
	return log.OFF
}

// Output middleware
func (l LogMiddleware) Output() io.Writer {
	return l.r.Out
}

// SetOutput middleware
func (l LogMiddleware) SetOutput(w io.Writer) {
	logrus.SetOutput(w)
}

// Prefix middleware
func (l LogMiddleware) Prefix() string {
	return ""
}

// SetLevel middleware
func (l LogMiddleware) SetLevel(lvl log.Lvl) {
	switch lvl {
	case log.DEBUG:
		logrus.SetLevel(logrus.DebugLevel)
	case log.WARN:
		logrus.SetLevel(logrus.WarnLevel)
	case log.ERROR:
		logrus.SetLevel(logrus.ErrorLevel)
	case log.INFO:
		logrus.SetLevel(logrus.InfoLevel)
	default:
		l.r.Panic("Invalid level")
	}
}

// SetPrefix middleware
func (l LogMiddleware) SetPrefix(s string) {
	// nil
}
