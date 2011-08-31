require "subpub/version"
require "subpub/error"

class Subpub
  SEPERATOR = "\r\n"
  SEPLENGTH = SEPERATOR.length
  COMMANDS  = ['PUBLISH', 'SUBSCRIBE', 'PSUBSCRIBE', 'UNSUBSCRIBE', 'PUNSUBSCRIBE']

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

end # class::Subpub
