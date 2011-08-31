require File.join(File.dirname(__FILE__), "spec_helper")

describe Subpub do
  it "should have a VERSION" do
    Subpub.const_defined?(:VERSION).should be true
  end # it "should have a VERSION"
  describe "VERSION" do
    subject { Subpub::VERSION }
    it { should be_a String }
  end # describe "VERSION"
end # Subpub