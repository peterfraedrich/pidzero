// pidzero daemon
// a docker process manager designed for docker

import haxe.sys.*;
import haxe.Timer;
import yaml.*;

class Pzd {
    // if name == main
    static public function main():Void {
        // do the stuff
        var log = new Logger('pzd.log');
        var loop = new EventLoop(log);
        log.debug('Started pidzero');
        loop.start();
    }
}

class EventLoop {
    public var log:Logger;
    public var desired_state = {};
    public var current_state = {};
    public var loop = new Timer(100);

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

    private function getDaemons() : Any {
        var units = {};
        var daemon = sys.FileSystem.readDirectory('pz.d');
        for (d in daemon) {

        }
        return units;
    }

    private function handle() : Void {
        // do the event loop things here

    }
}

class Logger {
    public var logpath:String;
    public var loglevel:String;
    public var outlog:Bool;
    public var filelog:Bool;


    public function new(logpath:String='/var/log/pzd', loglevel:String='info', outlog:Bool=true, filelog:Bool=true) : Void {
        this.logpath = logpath;
        this.loglevel = loglevel;
        this.outlog = outlog;
        this.filelog = filelog;
        return;
    }

    private function log(loglevel:String, logtext:String) : Void {
        var msg = '${Date.now()} :: ${loglevel} :: ${logtext}';
        if (this.outlog == true) {
            trace(msg);
        }
        if (this.filelog == true) {
            var f = sys.io.File.append(this.logpath);
            f.writeString('${msg}\n');
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
    public var replicas:Int;
    public var comments:String;
    public var pidstatus:Bool;
    public var pidrc:Int;
    private var p:sys.io.Process;

    public function new(name:String, command:String, vital:Bool, replicas:Int, comments:String) : Void {
        // return a new child process object
        this.name = name;
        this.command = command;
        this.vital = vital;
        this.replicas = replicas;
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

class ChildProcessStub {
    public var name:String;
    public var pid:Int;
    public var command:String;
    public var vital:Bool;
    public var replicas:Int;
    public var comments:String;
    public var pidstatus:Bool;
    public var pidrc:Int;
    private var p:sys.io.Process;

    public function new(name:String, command:String, vital:Bool, replicas:Int, comments:String) : Void {
        // return a new child process object
        this.name = name;
        this.command = command;
        this.vital = vital;
        this.replicas = replicas;
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
        return null;
    }

    public function output() : String {
        // get the process output from stdout + stderr
        return 'test';
    }
}
