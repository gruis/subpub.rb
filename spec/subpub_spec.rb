require File.join(File.dirname(__FILE__), "spec_helper")
require "stringio"

describe Subpub do
  it "should have a VERSION" do
    Subpub.const_defined?(:VERSION).should be true
  end # it "should have a VERSION"
  describe "VERSION" do
    subject { Subpub::VERSION }
    it { should be_a String }
  end # describe "VERSION"
  
  describe "#parse" do
    subject { Subpub.new }
    it { should respond_to(:parse) }
    
    it "should recognize a publish command" do
      msg     = %q!{"data" : "a message for you"}!
      channel = "data.json"
      parsed  = subject.parse(StringIO.new("*3\r\n$7\r\nPUBLISH\r\n$#{channel.size}\r\n#{channel}\r\n$#{msg.size}\r\n#{msg}\r\n"))
      parsed.should be_a(Array)
      parsed.should have(3).items
      parsed[0].should == 'PUBLISH'
      parsed[1].should == channel
      parsed[2].should == msg
    end # should recognize a publish command
    
    it "should recognize a subscribe command" do
      parsed = subject.parse(StringIO.new("SUBSCRIBE data.json\r\n"))
      parsed.should be_an(Array)
      parsed.should have(2).items
      parsed[0].should == "SUBSCRIBE"
      parsed[1].should == "data.json"
    end # should recognize a subscribe command
    
    it "should recognize the psubscribe command" do
      parsed = subject.parse(StringIO.new("PSUBSCRIBE data.*\r\n"))
      parsed.should be_an(Array)
      parsed.should have(2).items
      parsed[0].should == "PSUBSCRIBE"
      parsed[1].should == "data.*"
    end # should recognize the psubscribe command
    
    it "should recognize the unsubscribe command" do
      parsed = subject.parse(StringIO.new("UNSUBSCRIBE data.json\r\n"))
      parsed.should be_an(Array)
      parsed.should have(2).items
      parsed[0].should == "UNSUBSCRIBE"
      parsed[1].should == "data.json"
      
      parsed = subject.parse(StringIO.new("UNSUBSCRIBE data.json data.xml\r\n"))
      parsed.should be_an(Array)
      parsed.should have(3).items
      parsed[0].should == "UNSUBSCRIBE"
      parsed[1].should == "data.json"
      parsed[2].should == "data.xml"
      
      parsed = subject.parse(StringIO.new("UNSUBSCRIBE\r\n"))
      parsed.should be_an(Array)
      parsed.should have(1).items
      parsed[0].should == "UNSUBSCRIBE"
    end # should recognize the unsubscribe command

    it "should recognize the punsubscribe command" do
      parsed = subject.parse(StringIO.new("PUNSUBSCRIBE data.*\r\n"))
      parsed.should be_an(Array)
      parsed.should have(2).items
      parsed[0].should == "PUNSUBSCRIBE"
      parsed[1].should == "data.*"
    end # should recognize the psubscribe command


    it "should parse publish fast" do
      pending
      
      msg     = %q!{"data" : "a message for you"}!
      channel = "data.json"
      data = []
      150000.times { data.push(StringIO.new("*3\r\n$7\r\nPUBLISH\r\n$#{channel.size}\r\n#{channel}\r\n$#{msg.size}\r\n#{msg}\r\n")) }
      expect {
        data.each { |d| subject.parse(d) }
      }.to take_less_than(1.0).seconds
    end # should parse publish fast


  end # "parse"
end # Subpub
