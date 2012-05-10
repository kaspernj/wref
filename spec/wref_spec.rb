require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Wref" do
  it "should not fail" do
    #This test does not work under JRuby.
    if RUBY_ENGINE != "jruby"
      str = "Test"
      ref = Wref.new(str)
      raise "Should have been alive but wasnt." if !ref.alive?
      str = nil
      
      #In MRI we have to define another object finalizer, before the last will be finalized.
      str2 = "Test 2"
      ref2 = Wref.new(str2)
      ref2 = nil
      GC.start
      raise "Should have been GCed but wasnt." if ref.alive?
      
      
      str = "Test"
      map = Wref_map.new
      map[5] = str
      raise "Should have been valid but wasnt." if !map.valid?(5)
      str = nil
      GC.start
      raise "Should habe been garbage collected but wasnt." if !map.valid?(5)
    end
  end
end