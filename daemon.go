package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"syscall"
	"time"
)

// Daemon : Implements a Daemon object that can be referenced for each
// daemon listed in config.yaml
type Daemon struct {
	Name        string   `json:"name"`
	Command     string   `json:"command"`
	Args        []string `json:"args"`
	Description string   `json:"description"`
	Vital       bool     `default:"true" json:"vital"`
	Env         []string `json:"env"`
	dlog        bool
	Pid         int `default:"nil" json:"pid"`
	proc        exec.Cmd
	stdout      io.ReadCloser
	stderr      io.ReadCloser
	q           chan interface{}
	quit        chan *Daemon
	ready       chan bool
}

// start the daemon
func (d *Daemon) start() {
	d.ready = make(chan bool)
	subp := exec.Command(d.Command, d.Args...)
	d.stdout, _ = subp.StdoutPipe()
	d.stderr, _ = subp.StderrPipe()
	if d.dlog == true {
		go d.readStdout()
		go d.readStderr()
	}
	d.proc.Env = append(os.Environ(), d.Env...)
	err := subp.Start()
	go d.watch()
	if err != nil {
		d.log("fatal", "Unable to start daemon")
	}
	d.Pid = subp.Process.Pid
	d.proc = *subp
	for range []int{1, 2, 3} {
		d.ready <- true
	}
	d.log("info", "daemon started")
}

func (d *Daemon) watch() {
	<-d.ready
	d.proc.Wait()
	if d.Vital == true {
		d.quit <- d
	} else {
		d.log("info", "Daemon process exited.")
	}
}

func (d *Daemon) signal(s syscall.Signal) {
	d.proc.Process.Signal(s)
	if d.Vital == true {
		d.quit <- d
	} else {
		d.log("info", fmt.Sprintf("Sent signal %v to daemon", s))
	}
}

// stop the daemon
func (d *Daemon) kill() {
	d.proc.Process.Kill()
	if d.Vital == true {
		d.quit <- d
	} else {
		d.log("info", "daemon killed")
	}
}

func (d *Daemon) readStdout() {
	<-d.ready
	var stdout []byte

	outbuf := make([]byte, 1, 1)

	for {
		n, erro := d.stdout.Read(outbuf[:])
		if n > 0 {
			b := outbuf[:n]
			if string(b) == "\n" {
				d.log("debug", string(stdout))
				stdout = nil
			} else {
				stdout = append(stdout, b...)
			}
		}
		if erro == io.EOF {
			erro = nil
		}

	}
}

func (d *Daemon) readStderr() {
	<-d.ready
	var stderr []byte
	errbuf := make([]byte, 1, 1)
	e, erre := d.stderr.Read(errbuf[:])
	if e > 0 {
		q := errbuf[:e]
		if string(q) == "\n" {
			d.log("error", string(stderr))
			stderr = nil
		} else {
			stderr = append(stderr, q...)
		}
	}
	if erre == io.EOF {
		erre = nil
	}
	time.Sleep(1 * time.Nanosecond) // keep from locking up CPU
}

func (d *Daemon) log(l string, m string) {
	var logMessage = DaemonLog{
		msg:     m,
		level:   l,
		msgtype: "daemon",
		name:    d.Name,
		command: d.Command,
		args:    d.Args,
		vital:   d.Vital,
		env:     d.Env,
		pid:     d.Pid,
	}
	d.q <- &logMessage
}
