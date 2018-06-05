// pidzero daemon
// a docker process manager designed for docker

import haxe.sys.*;
import haxe.Timer;
import haxe.*;
import sys.*;

class Pzd {
    // if name == main
    static public function main():Void {
        // do the stuff
        var log = new Logger('pzd.log');
        var loop = new EventLoop(log);
        log.debug('Started pidzero');
        loop.start();
        var mainloop = new Timer(1000);
        mainloop.run = function () {
            //do the thing
        }
    }
}

class EventLoop {
    public var log:Logger;
    public var desired_state = {};
    public var current_state = {};
    public var loop = new Timer(100);
    private var counter:Int = 0;
    private var daemons:Any;
    private var firstrun:Bool = true;

    public function new(logger:Logger) : Void {
        this.log = logger;
        this.loop.run = this.handle;
    }

    public function start() : Void {
        this.loop.run();
        this.log.debug('Started new event loop.');
    }

    public function stop() : Void {
        this.loop.stop();
        this.log.debug('Event loop has been stopped.');
    }

    public function status() : Bool {
        return true;
    }

    private function getDaemons() : Void {
        var f = sys.io.File.getContent('daemons.json');
        var units = haxe.Json.parse(f);
        this.counter = 0;
        this.daemons = units;
    }

    private function runonce() : Void {
        this.getDaemons();
        this.spawn();
    }

    private function spawn() : Void {
        // spawn processes
        
    }

    private function handle() : Void {
        // do the event loop things here
        if (this.firstrun == true) {
            this.runonce();
        }
        if (this.counter % 100 == 0) {
            this.getDaemons();
        }

        this.counter++;
    }
}

class Logger {
    public var logpath:String;
    public var loglevel:String;
    public var outlog:Bool;
    public var filelog:Bool;
    public var jsonstdout:Bool;
    public var jsonfile:Bool;

    public function new(logpath:String='/var/log/pzd', loglevel:String='info', outlog:Bool=true, filelog:Bool=true, jsonstdout:Bool=false, jsonfile:Bool=true) : Void {
        this.logpath = logpath;
        this.loglevel = loglevel;
        this.outlog = outlog;
        this.filelog = filelog;
        this.jsonstdout = jsonstdout;
        this.jsonfile = jsonfile;
        return;
    }

    private function render(msg:Any, bit:Bool) : Any {
        if (bit == true) {
            return Json.stringify(msg);
        } else {
            return msg;
        }
    }

    private function log(loglevel:String, logtext:String, src:String='Main') : Void {
        //var msg = '${Date.now()} :: ${src} :: ${loglevel} :: ${logtext}';
        var msg = {
            timestamp : Date.now(),
            source    : src,
            loglevel  : loglevel,
            logtext   : logtext
        };
        if (this.outlog == true) {
            trace(this.render(msg, this.jsonstdout));
        }
        if (this.filelog == true) {
            var f = sys.io.File.append(this.logpath);
            f.writeString('${this.render(msg, this.jsonfile)}\n');
            f.flush();
            f.close();
        }
    }

    public function debug(text) : Void {
        this.log('DEBUG', text);
    }

    public function info(text) : Void {
        this.log('INFO ', text);
    }

    public function warn(text) : Void {
        this.log('WARN ', text);
    }

    public function ERROR(text) : Void {
        this.log('ERROR', text);
    }


}

class ChildProcess {
    public var name:String;
    public var pid:Int;
    public var command:String;
    public var vital:Bool;
    public var comments:String;
    public var pidstatus:Bool;
    public var pidrc:Int;
    private var p:sys.io.Process;

    public function new(name:String, command:String, vital:Bool, comments:String) : Void {
        // return a new child process object
        this.name = name;
        this.command = command;
        this.vital = vital;
        this.comments = comments;
        return;
    }

    public function start() : Bool {
        // start the child process here
        return true;
    }

    public function status() : Bool {
        // check the status of the process here
        return true;
    }

    public function rc() : Null<Int> {
        // return returncode
        return this.pidrc;
    }

    public function output() : String {
        // get the process output from stdout + stderr
        return 'test';
    }

}
