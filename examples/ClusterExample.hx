import js.node.Cluster.instance as cluster;
import js.node.Http;
import js.node.Os;
import js.node.NodeJS.console;

/**
	Example from the cluster api doc
**/
class ClusterExample {
	static function main() {
		var numCPUs = Os.cpus().length;
		if (cluster.isMaster) {
			// Fork workers.
			for (i in 0...numCPUs) {
				cluster.fork();
			}

			cluster.on('exit', function(worker, code, signal) {
				console.log('worker ' + worker.process.pid + ' died');
			});
		} else {
			// Workers can share any TCP connection
			// In this case its a HTTP server
			Http.createServer(function(req, res) {
				res.writeHead(200);
				res.end("hello world\n");
			}).listen(8000);
		}
	}
}