# ##############################################
# # Using TCPServer
# ##############################################

require 'socket'

class MyClient
	def initialize(socket)
		@socket = socket
		@request = send_request
		@response = listen_response

		@request.join # will send the request to server
		@response.join # will receive response from server
	end

	def send_request
		puts "Please enter your username to establish a connection: "
		# use begin rescue to catch error
		begin
			threadRequest = Thread.new do
				loop {
					msg = $stdin.gets.chomp
					@socket.puts msg    # server terminal print (received) the msg

					if msg == 'quit'
						@socket.close
						break
						# Thread.kill(threadRequest)
						# Thread.kill(threadResponse)
						# # kill all the thread??????
						# exit  #???????
						# simple_client.rb:46:in `gets': stream closed in another thread (IOError)
					end
				}
			end
		rescue IOError => e
			puts e.message
			# e.backtrace
			@socket.close
		end
	end

	def listen_response
		begin
			threadResponse = Thread.new do
				loop {
					response = @socket.gets.chomp  # getting msg from server (from other client)
					puts "#{response}"
				}
			end
		rescue IOError => e
			puts e.message
			# e.backtrace
			@socket.close
		end
	end

end


hostname = 'localhost'
port = 2000

socket = TCPSocket.open(hostname, port)
MyClient.new(socket)







# ##############################################
# # Using TCPServer -initial test
# ##############################################

# require 'socket'

# hostname = 'localhost'
# port = 2000

# s = TCPSocket.open(hostname, port)
# puts "Starting the Client..............."

# puts "Please enter your username to establish a connection...."

# loop {
# 	msg = $stdin.gets.chop
# 	s.puts msg

# 	response = s.gets.chop
# 	puts "#{response}"
# }

# # loop {
# # 	response = s.gets.chop
# # 	puts "#{response}"
# # }


# # while line = s.gets             # read lines from the socket
# # 	puts line.chop
# # end

# puts "Closing the Client.........."
# s.close                         # close the socket when done
