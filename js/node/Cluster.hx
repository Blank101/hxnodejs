package js.node;

import js.node.events.EventEmitter;
import js.node.cluster.Worker;

@:enum abstract ClusterEvent(String) to String {
	/**
		When a new worker is forked the cluster module will emit a 'fork' event.
		This can be used to log worker activity, and create your own timeout.

		Listener arguments:
			* worker:Worker
	**/
	var Fork = "fork";

	/**
		After forking a new worker, the worker should respond with an online message.
		When the master receives an online message it will emit this event.

		The difference between 'fork' and 'online' is that fork is emitted when the master forks a worker,
		and 'online' is emitted when the worker is running.

		Listener arguments:
			* worker:Worker
	**/
	var Online = "online";

	/**
		After calling `listen` from a worker, when the 'listening' event is emitted on the server,
		a listening event will also be emitted on cluster in the master.

		The event handler is executed with two arguments, the `worker` contains the worker object and
		the `address` object contains the following connection properties: address, port and addressType.
		This is very useful if the worker is listening on more than one address.

 		Listener arguments:
			* worker:Worker
			* address:ListeningEventAddress
	**/
	var Listening = "listening";

	/**
		Emitted after the worker IPC channel has disconnected.

		This can occur when a worker exits gracefully, is killed,
		or is disconnected manually (such as with `Worker.disconnect`).

		There may be a delay between the 'disconnect' and 'exit' events.

		These events can be used to detect if the process is stuck in a cleanup
		or if there are long-living connections.

		Listener arguments:
			* worker:Worker
	**/
	var Disconnect = "disconnect";

	/**
		When any of the workers die the cluster module will emit the 'exit' event.
		This can be used to restart the worker by calling `Cluster.fork` again.

		Listener arguments:
			* worker:Worker
			* code:Int - the exit code, if it exited normally.
			* signal:String - the name of the signal (eg. 'SIGHUP') that caused the process to be killed.
	**/
	var Exit = "exit";

	/**
		Emitted the first time that `Cluster.setupMaster` is called.
	**/
	var Setup = "setup";
}

/**
	Structure emitted by 'listening' event.
**/
typedef ListeningEventAddress = {
	var address:String;
	var port:Int;
	var addressType:ListeningEventAddressType;
}

@:enum abstract ListeningEventAddressType(haxe.EitherType<Int,String>) to haxe.EitherType<Int,String> {
	var TCPv4 = 4;
	var TCPv6 = 6;
	var Unix = -1;
	var UDPv4 = "udp4";
	var UDPv6 = "udp6";
}


/**
	A single instance of Node runs in a single thread.
	To take advantage of multi-core systems the user will sometimes want to launch a cluster of Node processes to handle the load.
	The cluster module allows you to easily create child processes that all share server ports.

	This feature was introduced recently, and may change in future versions. Please try it out and provide feedback.

	Also note that, on Windows, it is not yet possible to set up a named pipe server in a worker.
**/
@:jsRequire("cluster")
extern class Cluster extends EventEmitter
{
	/**
		A reference to the `Cluster` object returned by node.js module.

		It can be imported into module namespace by using: "import js.node.Cluster.instance in cluster"
	**/
	public static inline var instance:Cluster = cast Cluster;

	/**
		After calling `setupMaster` (or `fork`) this settings object will contain the settings, including the default values.

		It is effectively frozen after being set, because `setupMaster` can only be called once.

		This object is not supposed to be changed or set manually, by you.
	**/
	var settings(default,null):ClusterSettings;

	/**
		True if the process is a master.
		This is determined by the process.env.NODE_UNIQUE_ID.
		If process.env.NODE_UNIQUE_ID is undefined, then `isMaster` is true.
	**/
	var isMaster(default,null):Bool;

	/**
		True if the process is not a master (it is the negation of `isMaster`).
	**/
	var isWorker(default,null):Bool;

	/**
		`setupMaster` is used to change the default `fork` behavior.

		Once called, the `settings` will be present in `settings`.

		Note that:
			Only the first call to `setupMaster` has any effect, subsequent calls are ignored

			That because of the above, the only attribute of a worker that may be customized per-worker
			is the `env` passed to `fork`

			`fork` calls `setupMaster` internally to establish the defaults, so to have any effect,
			`setupMaster` must be called before any calls to `fork`
	**/
	function setupMaster(?settings:{?exec:String, ?args:Array<String>, ?silent:Bool}):Void;

	/**
		Spawn a new worker process.

		This can only be called from the master process.
	**/
	function fork(?enc:Dynamic<String>):Worker;

	/**
		Calls `disconnect` on each worker in `workers`.

		When they are disconnected all internal handles will be closed,
		allowing the master process to die gracefully if no other event is waiting.

		The method takes an optional `callback` argument which will be called when finished.

		This can only be called from the master process.
	**/
	function disconnect(?callback:Void->Void):Void;

	/**
		A reference to the current worker object.

		Not available in the master process.
	**/
	var worker(default,null):Worker;

	/**
		A hash that stores the active worker objects, keyed by `id` field.
		Makes it easy to loop through all the workers.

		It is only available in the master process.

		A worker is removed from `workers` just before the 'disconnect' or 'exit' event is emitted.

		Should you wish to reference a worker over a communication channel, using the worker's unique `id`
		is the easiest way to find the worker.
	**/
	var workers(default,null):Dynamic<Worker>;
}

typedef ClusterSettings = {
	/**
		list of string arguments passed to the node executable.
		Default: process.execArgv
	**/
	@:optional var execArgv(default,null):Array<String>;

	/**
		file path to worker file.
		Default: process.argv[1]
	**/
	@:optional var exec(default,null):String;

	/**
		string arguments passed to worker.
		Default: process.argv.slice(2)
	**/
	@:optional var args(default,null):Array<String>;

	/**
		whether or not to send output to parent's stdio.
		Default: false
	**/
	@:optional var silent(default,null):Bool;
}
