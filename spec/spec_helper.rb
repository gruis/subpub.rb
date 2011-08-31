require "subpub"
require 'benchmark'
require "timeout"

module Subpub::Test
  module RSpec
    
  end # module::RSpec
end # module::Subpub::Test

RSpec::Matchers.define :take_less_than do |n|
  chain :seconds do; end
  match do |block|
    @elapsed = Benchmark.realtime do
      block.call
    end
    (@elapsed).tap{|t| puts "time: #{t}"} <= n
  end # |block|
  failure_message_for_should do |block|
    "expected to take less than #{n}, but it took #{@elapsed}"
  end #  |block|
  failure_message_for_should_not do |block|
    "expected to take more than #{n}, but it took #{@elapsed}"
  end #  |block|
end # |n|