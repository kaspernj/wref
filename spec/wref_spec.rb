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
      map[6] = "trala"
      
      raise "Should have been valid but wasnt." if !map.valid?(5)
      str = nil
      
      #Test each-method.
      count = 0
      str_col = ""
      map.each do |a_str|
        count += 1
        str_col << a_str
      end
      
      raise "Expected collection to be 'Testtrala' but it wasnt: #{str_col}" if str_col != "Testtrala"
      raise "Expected count 2 but it wasnt: #{count}" if count != 2
      
      #Make the engine work a little to force garbage collection.
      0.upto(10) do
        str = "New str"
        ref = Wref.new(str)
        ref = nil
        
        str2 = "New string"
        ref2 = Wref.new(str2)
        ref2 = nil
        GC.start
      end
      
      #Test each-method.
      count = 0
      map.each do |a_str|
        count += 1
      end
      
      raise "Expected count 0 but it wasnt: #{count}" if count != 0
      raise "Should have been garbage collected but wasnt." if map.valid?(5)
    end
  end
end