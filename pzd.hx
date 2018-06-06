// pidzero daemon
// a docker process manager designed for docker

// TODO: turn event loops into threads, because this shit is dumb AF

import haxe.sys.*;
import haxe.Timer;
import haxe.*;
import sys.*;
#if cpp
    import cpp.vm.Thread;
#end
#if neko
    import neko.vm.Thread;
#end

class Pzd {
    // if name == main
    static public function main():Void {
        // do the stuff
        var log = new Logger('pzd.log');
        var loop = new EventLoop(log);
        log.debug('Started pidzero');
        loop.start();
        trace('main');
        while (true) {
            trace('true');
        }
    }
}

class Queue {
    public static var outq:Array<Dynamic> = [];
    public static var errq:Array<Dynamic> = [];
}

class EventLoop {
    public var log:Logger;
    public var procs:Array<ChildProcess> = [];
    public var loop = new Timer(100);
    private var counter:Int = 0;
    private var daemons:Array<Dynamic>;
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

    private function getDaemons() : Void {
        var f = sys.io.File.getContent('daemons.json');
        var units = haxe.Json.parse(f);
        this.counter = 0;
        this.daemons = units;
    }

    private function runonce() : Void {
        this.getDaemons();
        this.spawn();
        this.firstrun = false;
    }

    private function spawn() : Void {
        // spawn processes
        for (d in this.daemons) {
            var p = new ChildProcess(d.name, d.command, d.vital, d.comments, d.environment, this.log);
            var res = p.start();
            if (res == true) {
                this.procs.push(p);
            } else {
                this.log.error('Daemon ${d.name} did not start; failing.', 'class EventLoop() => method spawn()');
            }
        }
    }

    private function checkStatus() : Void {
        /// check process status
        for (p in this.procs) {
            trace(p.rc);
            if (p.rc != null) {
                this.log.info('Daemon ${p.name} exited with status code ${p.rc}.');
                if (p.vital == true) {
                    this.log.error('Daemon ${p.name} is marked as vital:${p.vital} and existed with code ${p.rc}.');
                }
            }
        }
    }

    private function getOutput() : Void {
        // get process output
        trace('go 1');
        var out = Queue.outq.shift();
        trace(out);
        if (out != null) {
            this.log.info(out[0], out[1]);
        }
        trace('go 2');
        var err = Queue.errq.shift();
        trace(err);
        if (err != null) {
            this.log.warn(err[0], err[1]);
        }
        trace('go 3');
        return;
    }

    private function handle() : Void {
        // do the event loop things here
        trace('*** START');
        if (this.firstrun == true) {
            this.runonce();
            trace('run1');
        }
        this.checkStatus();
        trace('checkStatus()');
        this.getOutput();
        trace('getOutput()');

        this.counter++;
        trace('counter++');
        trace('COUNTER: ${this.counter}');
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

    private function log(loglevel:String, logtext:String, src:String) : Void {
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
        if (loglevel == 'ERROR') {
            throw msg;
        }
    }

    public function debug(text:Null<String>=null, source:String='Main') : Void {
        this.log('DEBUG', text, source);
    }

    public function info(text:Null<String>=null, source:String='Main') : Void {
        this.log('INFO ', text, source);
    }

    public function warn(text:Null<String>=null, source:String='Main') : Void {
        this.log('WARN ', text, source);
    }

    public function error(text:Null<String>=null, source:String='Main') : Void {
        this.log('ERROR', text, source);
    }


}

class ChildProcess {
    public var name:String;
    public var pid:Int;
    public var command:String;
    public var vital:Bool;
    public var comments:String;
    public var environment:Array<Dynamic>;
    public var stdout:haxe.io.Input;
    public var stderr:haxe.io.Input;
    private var p:sys.io.Process;
    private var log:Logger;
    public var rc:Null<Int> = null;
    private var statusThread:Thread;
    private var outThread:Thread;
    private var errThread:Thread;


    public function new(name:String, command:String, vital:Bool, comments:String, environment:Array<Dynamic>, log:Logger) : Void {
        // return a new child process object
        this.name = name;
        this.command = command;
        this.vital = vital;
        this.comments = comments;
        this.environment = environment;
        this.log = log;
        return;
    }

    public function start() : Bool {
        // start the child process here
        try {
            this.p = new sys.io.Process(this.command);
            this.stdout = this.p.stdout;
            this.stderr = this.p.stderr;
            this.pid = this.p.getPid();
            this.statusThread = Thread.create(this.statusBlocking);
            this.outThread = Thread.create(this.readStdout);
            this.errThread = Thread.create(this.readStderr);
        } catch (e:Dynamic) {
            if (e) {
                this.log.warn(e, 'class ChildProcess() -> method start() -> ${this.name}');
                return false;
            }
        }
        return true;
    }

    public function stop() : Void {
        this.p.close();
        return;
    }

    public function status() : Null<Int> {
        // check the status of the process here
        return this.rc;
    }

    private function statusBlocking() : Void {
        this.rc = this.p.exitCode();
        return;
    }

    private function readStdout() : Void {
        var l = new Timer(100);
        l.run = function () {
            try {
                var d = [
                    'line' => this.stdout.readLine(),
                    'source' => this.name
                ];
                trace(d);
                Queue.outq.push(d);
            } catch (e:Dynamic) {
                if (e != 'Eof') {
                    trace(e);
                    this.log.error(e, this.name);
                }
            }
        }
        l.run();
        return;
    }

    private function readStderr() : Void {
        var l = new Timer(100);
        l.run = function () {
            try {
                var d = [
                    'line' => this.stderr.readLine(),
                    'source' => this.name
                ];
                trace(d);
                Queue.errq.push(d);
            } catch (e:Dynamic) {
                if (e != 'Eof') {
                    trace(e);
                    this.log.error(e, this.name);
                }
            }
        }
        l.run();
        return;
    }

}
