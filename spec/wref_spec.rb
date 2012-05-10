require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Wref" do
  it "should not fail" do
    str = "Test"
    ref = Wref.new(str)
    raise "Should have been alive but wasnt." if !ref.alive?
    str = nil
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