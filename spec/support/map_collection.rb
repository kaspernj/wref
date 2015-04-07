shared_examples_for "map" do
  include GarbageCollectorHelper

  let(:str) { "Test 5" }

  let(:map) do
    class_name = described_class.name

    if match = class_name.match(/::([A-z]+)$/)
      impl = match[1].to_sym if match[1] != "Map"
    end

    map = Wref::Map.new(impl: impl)
    map[5] = str
    map[6] = "Test 6"
    map
  end

  it "#valid?" do
    map.valid?(5).should eq true
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
    str_col.should eq "Test 5Test 6"
    count.should eq 2
  end

  it "#length" do
    map.length.should eq 2
  end

  it "#length_valid" do
    map.length_valid.should eq 2

    force_garbage_collection

    map.length_valid.should eq 1
  end

  it "#delete" do
    map.delete(5).should eq "Test 5"
    map.length.should eq 1
    map.length_valid.should eq 1
  end

  it "#key?" do
    map.key?(5).should eq true
    map.key?(6).should eq true
    map.key?(7).should eq false

    force_garbage_collection

    map.key?(6).should eq false
  end

  it "works with gc" do
    string = str
    map
    force_garbage_collection

    #Test each-method.
    count = 0
    map.each do |key, a_str|
      count += 1
    end

    count.should eq 1
    map.valid?(5).should eq true
    map.valid?(6).should eq false

    map.get(5).should eq "Test 5"
    map.get(6).should eq nil

    map.get!(5).should eq "Test 5"
    expect { map.get!(6) }.to raise_error(Wref::Recycled)
  end
end
