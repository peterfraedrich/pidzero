// pidzero daemon
// a docker process manager designed for docker

// TODO: turn event loops into threads, because this shit is dumb AF

import haxe.sys.*;
import haxe.Timer;
import haxe.*;
import sys.*;
#if cpp
    import cpp.vm.Thread;
    import cpp.vm.*;
#end
#if neko
    import neko.vm.Thread;
#end

class Pzd {
    // if name == main
    static public function main():Void {
        // do the stuff
        Config.loadConfig();
        Log.debug('Starting pidzero');
        while (true) {
            if (EventLoop.init == false) {
                EventLoop.runOnce();
            }
            EventLoop.getOutput();
            EventLoop.checkStatus();
            EventLoop.counter++;
        }
    }
}

class Config {
    public static var c:Null<Dynamic>;
    public static function loadConfig() : Void {
        var j = sys.io.File.getContent('config.json');
        Config.c = haxe.Json.parse(j);
        return;
    }
}

class Queue {
    public static var outq:Array<Dynamic> = [];
    public static var errq:Array<Dynamic> = [];
}

class Log {

    private static function render(msg:Any) : Any {
        if ( Config.c.log.json == true) {
            return Json.stringify(msg);
        } else {
            return msg;
        }
    }

    private static function log(loglevel:String, logtext:String, src:String) : Void {
        var msg = {
            timestamp : Date.now(),
            source    : src,
            loglevel  : loglevel,
            logtext   : logtext
        };
        if (Config.c.log.log_to_stdout == true) {
            trace(Log.render(msg));
        }
        if (Config.c.log.log_to_file == true) {
            var f = sys.io.File.append(Config.c.log.file_path);
            f.writeString('${Log.render(msg)}\n');
            f.flush();
            f.close();
        }
        if (loglevel == 'ERROR') {
            throw msg;
        }
    }

    public static function debug(text:Null<String>=null, source:String='Main') : Void {
        Log.log('DEBUG', text, source);
    }

    public static function info(text:Null<String>=null, source:String='Main') : Void {
        Log.log('INFO ', text, source);
    }

    public static function warn(text:Null<String>=null, source:String='Main') : Void {
        Log.log('WARN ', text, source);
    }

    public static function error(text:Null<String>=null, source:String='Main') : Void {
        Log.log('ERROR', text, source);
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
    public var rc:Null<Int> = null;
    private var statusThread:Thread;
    private var outThread:Thread;
    private var errThread:Thread;


    public function new(name:String, command:String, vital:Bool, comments:String, environment:Array<Dynamic>) : Void {
        // return a new child process object
        this.name = name;
        this.command = command;
        this.vital = vital;
        this.comments = comments;
        this.environment = environment;
        return;
    }

    public function start() : Bool {
        // start the child process here
        try {
            var e = this.envConvert(this.environment)
            this.p = new sys.io.Process(this.command);
            this.stdout = this.p.stdout;
            this.stderr = this.p.stderr;
            this.pid = this.p.getPid();
            this.statusThread = Thread.create(this.statusBlocking);
            this.outThread = Thread.create(this.readStdout);
            this.errThread = Thread.create(this.readStderr);
        } catch (e:Dynamic) {
            if (e) {
                Log.warn(e, 'class ChildProcess() -> method start() -> ${this.name}');
                return false;
            }
        }
        return true;
    }

    public function envConvert(env) : Any {
        
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
        var pos:Int = 0;
        l.run = function () {
            try {
                var txt:String = '';
                while (true) {
                    var b:String = this.stdout.read(1).toString();
                    if (b == '\n') {
                        var d = [
                            'line' => txt,
                            'source' => this.name
                        ];
                        Queue.outq.push(d);
                        txt = '';
                        pos++;
                        continue;
                    }
                    txt += b;
                    pos++;
                }
            } catch (e:Dynamic) {
                if (e != 'Eof') {
                    trace(e);
                    Log.error(e, this.name);
                }
            }
        }
        l.run();
        return;
    }

    private function readStderr() : Void {
        var l = new Timer(100);
        var pos:Int = 0;
        l.run = function () {
            try {
                var txt:String = '';
                while (true) {
                    var b:String = this.stderr.read(1).toString();
                    if (b == '\n') {
                        var d = [
                            'line' => txt,
                            'source' => this.name
                        ];
                        Queue.errq.push(d);
                        txt = '';
                        pos++;
                        continue;
                    }
                    txt += b;
                    pos++;
                }
            } catch (e:Dynamic) {
                if (e != 'Eof') {
                    trace(e);
                    Log.error(e, this.name);
                }
            }
        }
        l.run();
        return;
    }

}

class EventLoop {

    public static var procs:Array<ChildProcess> = [];
    public static var counter:Int = 0;
    public static var daemons:Array<Dynamic>;
    public static var init:Bool = false;
    public static var loop:Thread;
    public static var status:Int;

    public static function runOnce() : Void {
        EventLoop.getDaemons();
        EventLoop.spawn();
        EventLoop.init = true;
        Log.debug('Completed first run tasks.', 'EventLoop.runOnce');
        return;
    }

    public static function getDaemons() : Void {
        var f = sys.io.File.getContent('daemons.json');
        var units = haxe.Json.parse(f);
        EventLoop.daemons = units;
        return;
    }

    public static function spawn() : Void {
        for (d in EventLoop.daemons) {
            var p = new ChildProcess(d.name, d.command, d.vital, d.comments, d.environment);
            var res = p.start();
            if (res == true) {
                EventLoop.procs.push(p);
            } else {
                Log.error('Daemon ${d.name} failed to start; failing', 'EventLoop.spawn');
            }
        }
        return;
    }

    public static function checkStatus() : Void {
        for (p in EventLoop.procs) {
            if (p.rc != null) {
                Log.info('Daemon ${p.name} exited with status code ${p.rc}', 'EventLoop.checkStatus');
                if (p.vital == true) {
                    Log.error('${p.name} has exited and is marked as vital.', 'EventLoop.checkStatus');
                }
            }
        }
        return;
    }

    public static function getOutput() : Void {
        var out = Queue.outq.shift();
        if (out != null) {
            Log.info(out.get('line'), out.get('source'));
        }
        var err = Queue.errq.shift();
        if (err != null) {
            Log.warn(err.get('line'), err.get('source'));
        }
        return;
    }


}
