package main

import (
	"github.com/Sirupsen/logrus"
)

// Args : command line args
var Args = struct {
	configFile string
}{}

// GenericLog - generic log format
type GenericLog struct {
	msg     string
	level   string
	msgtype string
}

// APILog - log format for API
type APILog struct {
	msgtype string `default:"API"`
	msg     string
	level   string
	uri     string
	method  string
	status  int
	query   string
}

// DaemonLog - log format for daemon logging
type DaemonLog struct {
	msgtype string `default:"daemon"`
	msg     string
	level   string
	name    string
	command string
	args    []string
	vital   bool
	env     []string
	pid     int
}

// ProcessLog - log format for process logging
type ProcessLog struct {
	msgtype string `default:"process"`
	msg     string
	level   string
	daemon  string
	pipe    string
}

// AppLog - log format for main
type AppLog struct {
	msgtype string `default:"main"`
	msg     string
	level   string
	event   string
}

// Ping - ping/pong
type Ping struct {
	Ping string `default:"pong" json:"ping"`
}

// Proc - process object
type Proc struct {
	Name          string   `json:"name"`
	Pid           int32    `json:"pid"`
	Command       string   `json:"command"`
	MemoryVirtual uint64   `json:"memvirt"`
	MemorySwap    uint64   `json:"memswap"`
	CPU           float64  `json:"cpu_pct"`
	CPUTimes      CPUTimes `json:"cpu_times"`
	Status        string   `json:"status"`
	IsRunning     bool     `json:"running"`
}

// CPUTimes - cpu times struct
type CPUTimes struct {
	User   float64 `json:"user"`
	System float64 `json:"system"`
	Idle   float64 `json:"idle"`
}

func getLogLevel(s string) logrus.Level {
	switch s {
	case "debug":
		return logrus.DebugLevel
	case "info":
		return logrus.InfoLevel
	case "warn":
		return logrus.WarnLevel
	case "error":
		return logrus.ErrorLevel
	case "fatal":
		return logrus.FatalLevel
	default:
		return logrus.InfoLevel
	}
}
