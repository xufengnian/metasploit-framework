require 'Rex/Socket'
require 'Rex/Socket/Tcp'
require 'Rex/Socket/TcpServer'

###
#
# Local
# -----
#
# Local communication class factory.
#
###
class Rex::Socket::Comm::Local

	#
	# Creates an instance of a socket using the supplied parameters.
	#
	def self.create(param)
		case param.proto
			when 'tcp'
				return create_tcp(param)
			else
				raise RuntimeError, "Unsupported protocol: #{param.proto}", caller # FIXME EXCEPTION
		end
	end

	#
	# Creates a TCP socket 
	#
	def self.create_tcp(param)
		# Create the raw TCP socket
		sock = ::Socket.new(::Socket::AF_INET, 'tcp', 0)

		# Bind to a given local address and/or port if they are supplied
		if (param.localhost || param.localport)
			sock.bind(to_sockaddr(param.localhost, param.localport))
		end

		# If a server TCP instance is being created...
		if (param.server?)
			sock.listen(32)

			return sock if (param.bare?)

			return Rex::Socket::TcpServer.new(sock)	
		# Otherwise, if we're creating a client...
		else
			sock.connect(to_sockaddr(param.peerhost, param.peerport))

			return sock if (param.bare?)

			return Rex::Socket::Tcp.new(sock)
		end
	end

end
