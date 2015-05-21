//Setup a server on port 9998 to accept incomming connections
var io = require('socket.io')();
var rl = require('readline');

var r = rl.createInterface({
  input: process.stdin,
  output: new require('stream').Writable(),
  terminal: false
});

var stdin = process.stdin;

_socket = null;

//stdin.resume();
r.on("line", function(chunk) {
  var res = JSON.parse(chunk.toString());
  type = res.type;
  msg = res.msg;
  console.error("Sending" + type);
  console.error("Sending" + JSON.stringify(msg));
  _socket.emit(type, msg);
});

io.on('connection', function(socket) {
  _socket = socket;
  console.log("CLIENT CONNECTED");

  socket.on("test", function(data) {
    console.log(JSON.stringify(data));
  });
});
io.listen(9998);

function call() {
  console.log("STARTED");
}
setTimeout(call, 1000);
