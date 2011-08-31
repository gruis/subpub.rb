require "socket"  
require "subpub/version"
require "subpub/error"

class Subpub
  SEPERATOR = "\r\n"
  SEPLENGTH = SEPERATOR.length
  COMMANDS  = ['PUBLISH', 'SUBSCRIBE', 'PSUBSCRIBE', 'UNSUBSCRIBE', 'PUNSUBSCRIBE']
  
  def initialize
    @subscriptions = {}
  end # initialize
  
  def listen(port = 6379, host = 'localhost')
    srv = TCPServer.new(host, port)
    puts "listening on #{srv.addr[2]}:#{srv.addr[1]}"
    loop do  
      Thread.start(srv.accept) do |client|
        puts "connection from #{client.peeraddr[2]}:#{client.peeraddr[1]}"
        while IO.select([client], nil, nil, nil)
          begin
            respond(client, route(client, parse(client)))
          rescue SystemExit => e
            respond(client, "+OK")
            Process.exit
          rescue Exception => e
            puts e
            respond(client, "-#{e}")
          end # begin
        end # IO.select([client], nil, nil, nil)
      end # do |client|
    end # loop do
  end # listen(port = 6379, ip = nil)
  
  # Parse input
  # @param [IO] io
  # @return [Array] [command, arg1, arg2, ...]
  def parse(io)
    start = io.readline(SEPERATOR).chomp
    # Inline Command
    return start[0..-1].split(" ") if start[0] != "*"
    # Unified Request Protocol
    input = []
    start[1..-1].to_i.times do
      len = io.readline(SEPERATOR).chomp
      raise ByteLengthExpected unless len[0] == '$' && (len = len[1..-1].to_i) > 0
      input.push(io.read(len))
      raise ParseError unless io.read(SEPLENGTH) == SEPERATOR
    end # 
    input
  end # parse(io)
  
  
  # Take a command with variable number of arguments and route it to the 
  # appropriate processing method.
  # @param [Socket] socket
  # @param [Array] input [command, arg1, arg2, ... ]
  def route(socket, input)
    puts "route(#{socket}, #{input})"
    case input[0]
    when 'PUBLISH'
      publish(input[1], input[2])
    when 'SUBSCRIBE'
      subscribe(socket, input[1..-1])
    when 'PSUBSCRIBE'
      psubscribe(socket, input[1..-1])
    when 'UNSUBSCRIBE'
      unsubscribe(socket, input[1..-1])
    when 'PUNSUBSCRIBE'
      punsubscribe(socket, input[1..-1])
    when 'EXIT'
      Process.exit
    else
      raise UnrecognizedCommand, input[0]
    end # input[0]
  end # route(input)
  
  
  
private

  def subscription_add(socket, channel)
    @subscriptions[channel] ||= []
    @subscriptions[channel].push(socket) unless @subscriptions[channel].include?(socket)
  end # subscription_add(socket, channel)

  def subscription_del(socket, channel)
    (@subscriptions[channel] ||= []).delete(socket)
  end # subscription_del(socket, channel)

  def subscription_cnt(socket)
    @subscriptions.keys.inject(0) {|sum, chan| @subscriptions[chan].include?(socket) ? sum + 1 : sum }
  end # subscription_cnt(socket)
  
  
  
  def subscribe(socket, channels)
    reply = ""
    channels.each do |channel|
      subscription_add(socket, channel)
      reply += "*3#{SEPERATOR}$9#{SEPERATOR}subscribe#{SEPERATOR}$#{channel.length}#{SEPERATOR}#{channel}#{SEPERATOR}:#{subscription_cnt(socket)}#{SEPERATOR}"
    end #  |channel|
    reply
  end # subscribe(socket, channels)
  
  def psubscribe(socket, channels)
    reply = ""
    channels.each do |channel|
      # ...
    end #  |channel|
    reply
  end # psubscribe(socket, channels)
  
  def unsubscribe(socket, channels)
    reply = ""
    channels = @subscriptions.keys.select{|chan| @subscriptions[chan].include?(socket) } if channels.empty?
    channels.each do |channel|
      subscription_del(socket, channel)
      reply += "*3#{SEPERATOR}$11#{SEPERATOR}unsubscribe#{SEPERATOR}$#{channel.length}#{SEPERATOR}#{channel}#{SEPERATOR}:#{subscription_cnt(socket)}#{SEPERATOR}"
    end #  |channel|
    reply
  end # unsubscribe(socket, channels)

  def punsubscribe(socket, channels)
    reply = ""
    channels.each do |channel|
      # ...
    end #  |channel|
    reply
  end # punsubscribe(socket, channels)
  
  def publish(channel, msg)
    # ...
    "+OK"
  end # publish(channel, msg)
  
  
  
  # Send a response message back to a socket.
  def respond(io, msg)
    puts "respond(#{io}, #{msg})"
    begin
      io.write_nonblock(msg[-2..-1] == SEPERATOR ? msg : msg + SEPERATOR)
    rescue IO::WaitWritable, Errno::EINTR
      IO.select(nil, [io])
      retry
    end
  end # respond(io, msg)

end # class::Subpub
