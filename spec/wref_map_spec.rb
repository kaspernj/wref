require "spec_helper"

describe Wref::Map do
  let(:str) { "Test" }
  let(:gc) do
    GC.enable
    GC.start

    10000.times do
      some_str = "#{Digest::MD5.hexdigest(Time.now.to_f.to_s)}".clone
      some_str = nil
    end

    GC.enable
    GC.start
  end

  let(:map) do
    map = Wref::Map.new
    map[5] = str
    map[6] = "trala"
    map
  end

  it "#valid?" do
    map = Wref::Map.new
    map[5] = str
    map[6] = "trala"

    raise "Should have been valid but wasnt." if !map.valid?(5)
  end

  it "#each" do
    count = 0
    str_col = ""
    key_col = ""

    map.each do |key, a_str|
      count += 1
      str_col << a_str
      key_col << key.to_s
    end

    key_col.should eq "56"
    str_col.should eq "Testtrala"
    count.should eq 2
  end

  it "#length" do
    map.length.should eq 2
  end

  it "#length_valid" do
    map
    gc
    map.length_valid.should eq 1
  end

  it "#delete" do
    map.delete(5).should eq "Test"
    map.length.should eq 1
    map.length_valid.should eq 1
  end

  it "#delete_by_id" do
    map.delete_by_id(str.__id__).should eq "Test"
    map.length.should eq 1
    map.length_valid.should eq 1
  end

  it "#key?" do
    map.key?(5).should eq true
    map.key?(6).should eq true
    map.key?(7).should eq false

    gc

    map.key?(6).should eq false
  end

  it "works with gc" do
    map
    gc

    #Test each-method.
    count = 0
    map.each do |key, a_str|
      count += 1
    end

    count.should eq 1
    map.valid?(5).should eq true
    map.valid?(6).should eq false

    map.get(5).should eq "Test"
    map.get(6).should eq nil

    map.get!(5).should eq "Test"
    expect { map.get!(6) }.to raise_error(Wref::Recycled)
  end
end
