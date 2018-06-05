// pidzero daemon
// a docker process manager designed for docker

import haxe.sys.*;

class Pzd {
    // if name == main
    static public function main():Void {
        // do the stuff
        trace('**** Start pzd');
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
    public var rc:Int;
    private var p:sys.io.Process;

    public function new(name:String, command:String, vital:Bool, replicas:Int, comments:String) {
        // return a new child process object
        this.name = name;
        this.command = command;
        this.vital = vital;
        this.replicas = replicas;
        this.comments = comments;
    }

    public function start() {
        // start the child process here
    }

    public function status() {
        // check the status of the process here
    }

    public function output() {
        // get the process output from stdout + stderr
    }

}
