class Subpub
  module Error; end
  class StandardError < ::StandardError
    def initialize(*args)
      super(*args)
      extend Error
    end # initialize(*args)
  end # StandardError < ::StandardError
  class ParseError < StandardError; end
  class ByteLengthExpected < ParseError; end
  class UnrecognizedCommand < StandardError; end
end # class::Subpub