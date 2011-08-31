#!/usr/bin/env ruby -wW1

require "subpub"

port = 6379
opts = OptionParser.new

opts.on("-p", "--port Fixnum", Integer, "the port (#{port}) to listen on") { |p| port = p }
opts.parse(ARGV)

Subpub.new.listen(port)
