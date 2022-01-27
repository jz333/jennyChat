# ##############################################
# # Using TCPServer
# ##############################################

require 'socket'

class MyClient
	def initialize(socket)
		@socket = socket
		@request = send_request   # start thread 1, will send the request to server
		@response = listen_response # start thread 2, ceive response from server

		# need to make sure main thread does not exit
		# you can do this by joining one thread (either one)
		# or just do a forever loop - but need to handle 'quit' differently

		@request.join # to prevent main thread finish running and exit
		# after the @request.join, nothing will run here (after the call) if request thread is not finished
		#@response.join # can join either child thread
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
		threadResponse = Thread.new do
			# use begin rescue outside of the loop to catch stream closed in another thread error!!
			begin
				loop {
					begin
						# when server crtlC, will generate error below as @socket is nil
						# undefined method `chomp' for nil:NilClass (NoMethodError)
						# catch the exception to gracefully exit
						response = @socket.gets.chomp  # getting msg from server (from other client)
						puts "#{response}"
					rescue NoMethodError => e
						#puts e.message
						puts "Server disconnected. Exiting..."
						exit
					end
				}
			rescue IOError => e
				#puts e.message  # stream closed in another thread
				puts "Disconnecting..."
				# e.backtrace
				#@socket.close
			end
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
