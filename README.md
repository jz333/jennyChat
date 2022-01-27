# jennyChat

## Using TCPSocket to build a simple chat program with 'socket' from Ruby Standard Library


### Socket
Sockets are endpoints of a bidirectional communication channel, clients and servers both use sockets to communicate. Once a peer-to-peer connection between a client and the server is established, both sides can send data into the sockets and it will be received on the other ends.

TCPSocket represents a TCP/IP client socket. (Note that TCPSocket is not the same as WebSocket - TCPSocket is on the low level end.) That is, th ecommunication protocal used in the socket is Transmission Control Protocol (TCP).

One end of a peer-to-peer connection of a TCP/IP based distributed network application described by a socket is uniquely defined by Internet address, communicaiton protocol, and Port number.

Ruby has it's own 'socket' class, we only need to require this class for this whole application.


### Application purpose
This is the backend self-testable local version of my chatting website project. The server will run in terminal, it will accecpt as many clients (other terminal process running the client side ruby script) as desired into the chat room. Each client is asked to enter a username to start. Messages sent from one client will be received by the server and then resend out to all other connected clients. This functions as a barebone verison of a chat group.


### Server side
Setting up a TCPServer is easy. From the example in the documentation, randomly select a local port.
```ruby
require 'socket'

server_socket = TCPServer.open('localhost', 2000) # here I randomly used port 2000
```
The socket is set up and running on port 2000, it will be actively listening to any attempt of connecting from clients - This is done in a loop to enable the server to run 'forever' while waiting for clients to connect.
```ruby
loop {
  client = server_socket.accept

  # open thread for each accepted connection
  Thread.start(client) do |connection|
    # use connection.gets for getting message from the server
    # use connection.puts for sending message to the server (display on server side terminal)
  end

}
```
Here the tricky part is to prevent error messages filling up your server side terminal when a connected client terminates its process/connection with an exception (keyboard interruption like pressing ctrl+C). We can simply use IO#EOF to check that.
```ruby
if connection.eof?
  next  # enter next loop to wait for new client connection
end
```
I also stored the client username (first prompt input by client) as key and it's socket connection as value (looks something like this: #\<TCPSocket:0x0000000104741418>) in a hash. The program is then able to check if the username is in use (connected already) and to keep track of the sender of messages.

If a user wants to exit the chat room, simply input "quit". Then the program will close the connection with this client. Be careful that you need to exit the loop in your code so that the program won't stuck in the loop trying to use method on a closed connection (stream).
```ruby
loop {
  # check connection.eof

  # get msg from client:
  msg = connection.gets.chomp

  if msg == 'quit'
    # notify other users that this client has left
    # delete this user from our hash

    puts "Connection with #{user_name} is ended."
    connection.close
    break # exit the loop!

  else
    # each client in the hash gets the msg
    connected_clients.keys.each do |client|
      connected_clients[client].puts "#{user_name}: #{msg}"
    end
  end
}
```
Note that the loop above is inside the outer loop of accepting new clients.


### Client side
Set up a TCPSocket to the same address (host and port) as chosen in the server socket set up. Simply follow the example in the ruby docments will do.
```ruby
require 'socket'

socket = TCPSocket.open('localhost', 2000)
```
Now the socket is open and running on the same address as the server, a connection is established.
Our client side should be able to send messages to the server and also listen to the response from the server. To achieve this, we use two separate threads for each task.
Send messages to server:
```ruby
threadRequest = Thread.new do
  loop {
    msg = $stdin.gets.chomp
    socket.puts msg # send msg to server

    if msg == 'quit'
      socket.close
      break
    end
  }
end
```
Listen to the response from server:
(Note that if server terminates, or the client inputs 'quit
' the below code will handle the error and exit gracefully.)
```ruby
threadResponse = Thread.new do
  begin
    loop {
      begin
        response = socket.gets.chomp # getting msg from server
        puts response
      rescue NoMethodError => e
        puts "Server disconnected. Exiting..."
        exit
      end
    }
  rescue IOError => e
    puts "Disconnecting..."  # handles when client input 'quit'
  end
end
```
In order to keep the main thread running while these two child threads are running, we can either
- running a forever loop after the two Thread.new call and set up some conditions in the loop to exit when server terminates or client inputs 'quit'.

- Or we can use thread's join method to join one of the thread: when calling for example ```threadRequest.join```, the calling thread (parent thread, which is the main thread) will suspend execution, thus prevent the main thread finishing execution and exit the program, and run this threa 'threadRequest'. Because both child threads are running after they are created, and all they do is looping some code - using join on one thread will not change much of what's going on except suspending the main thread and keep the program running and running.








