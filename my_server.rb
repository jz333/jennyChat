##############################################
# Using TCPServer
##############################################
require 'socket'


class MyServer
	def initialize(socket_port, socket_host)
		# @server_socket is my server's socket
		@server_socket = TCPServer.open(socket_host, socket_port)  
		# Server will listen on port socket_port

		@connections = Hash.new   # hash storing server and client info
		@connected_clients = Hash.new  # hash storing established clients info

		@connections[:server] = @server_socket
		@connections[:clients] = @connected_clients

		puts "JennyChat Server started!"

		run_server
	end

	def run_server
		loop {                             # server runs forever

			client = @server_socket.accept      # establish client connection, wait for a client to connect

			Thread.start(client) do |connection|  # open thread for each accepted connection
				# client.puts will display on client side terminal; when adding thread
				# loop through each connection (as a client)
				# so now connection.puts will display on this client side terminal


				# specify client side so their first prompt input is username
				# get msg from client side by using connection.gets
				if connection.eof?   # if client terminated with exception (ctrlC) then eof is true
					next
				end

				user_name = connection.gets.chomp.to_sym  # to symbol

				# check if username exists, do not connect if user exists already
				while (@connected_clients[user_name] != nil)
					connection.puts "This username already exists."
					connection.puts "Please use different username: "
					user_name = connection.gets.chomp.to_sym  # to symbol
				end

				puts "Connection established #{user_name} => #{connection}"

				# add this client to hash
				@connected_clients[user_name] = connection

				connection.puts "Connection established successfully #{user_name} => #{connection}"
				connection.puts "Welcome to the chat room!"

				# announce to other user a new client is joining
				@connected_clients.keys.each do |client|
					if client != user_name
						@connected_clients[client].puts "#{user_name} has joined!"
					end
				end

				establish_chat(user_name, connection)  # allow chatting

			end

		}  # no need to join here!
	end

	def establish_chat(user_name, connection)
		loop {

			if connection.eof?   # if client terminated with exception (ctrlC) then eof is true
				puts "Connection with #{user_name} lost."
				@connected_clients.delete(user_name) # delete this user from hash
				break
			end

			#msg = $stdin.gets.chomp
			msg = connection.gets.chomp   # getting msg from other user

			if msg == 'quit'
				@connected_clients.keys.each do |client|
					@connected_clients[client].puts "#{user_name} has left the chat room."
				end
				connection.close
				@connected_clients.delete(user_name) # delete this user from hash
				puts "Connection with #{user_name} is ended."
				break   ############# exit the loop
			
			else

				@connected_clients.keys.each do |client|
					@connected_clients[client].puts "#{user_name}: #{msg}"
				end
				#client.puts msg

				#res = client.gets.chomp
				#puts res
			end

		}
	end

end



# establish a server
MyServer.new(2000, "localhost")




# ##############################################
# # Using TCPServer -initial test
# ##############################################
# require 'socket'

# puts "Starting the Server.................."
# my_server = TCPServer.open(2000)   # socket to listen on port 2000

# loop {                             # server runs forever

# 	client = my_server.accept      # wait for a client to connect
# 	con_name = client.gets.chop

# 	puts "Connection established #{con_name}"

# 	loop {
# 		msg = $stdin.gets.chop
# 		client.puts msg

# 		res = client.gets.chop
# 		puts res
# 	}


# 	# client.puts(Time.now.ctime)    # send the time to the client
# 	# client.puts "Closing the connection with #{client}."
# 	# client.close                   # Disconnect from the client

# }







# ##############################################
# # Using EM-WebSocket
# ##############################################
# require 'em-websocket'

# $channel = EventMachine::Channel.new


# EM.run {

# 	EM::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
# 		ws.onopen { |handshake|
# 			puts "WebSocket connection open"

# 			# Access properties on the EM::WebSocket::Handshake object,e.g.,
# 			# path, query_string, origin, headers

# 			# Publist message to the client
# 			ws.send "Hello Client, you connected to #{handshakepath}"

# 			sid = $channel.subscribe { |msg| ws.send msg}
# 			$channel.push "#{sid} connected!"
# 			puts "client connected"

# 			ws.onmessage { |msg|
# 				$channel.push "<#{sid}>: #{msg}"
# 				puts "msg: #{msg}"
# 			}

# 			ws.onclose {
# 				$channel.unsubscribe(sid)
# 			}

# 		}

# 		ws.onclose { puts "Connection closed."}

# 		ws.onmessage { |msg|
# 			puts "Recieved message: #{msg}"
# 			ws.send "Pong: #{msg}"
# 		}
# 	end

# 	puts "Server started."

# }
