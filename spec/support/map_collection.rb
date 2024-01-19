shared_examples_for "map" do
  include GarbageCollectorHelper

  let(:user) { User.new("Kasper") }

  let(:map) do
    class_name = described_class.name

    if match = class_name.match(/::([A-z]+)$/)
      impl = match[1].to_sym if match[1] != "Map"
    end

    map = Wref::Map.new(impl: impl)
    map[5] = user
    map[6] = User.new("Morten")
    map
  end

  it "#valid?" do
    map.valid?(5).should eq true
  end

  it "#each" do
    count = 0
    str_col = ""
    key_col = ""

    map.each do |key, user|
      count += 1
      str_col << user.name
      key_col << key.to_s
    end

    key_col.should eq "56"
    str_col.should eq "KasperMorten"
    count.should eq 2
  end

  it "#each_key" do
    count = 0
    key_col = ""

    map.each_key do |key|
      count += 1
      key_col << key.to_s
    end

    key_col.should eq "56"
    count.should eq 2
  end

  it "#each_value" do
    count = 0
    str_col = ""

    map.each_value do |user|
      count += 1
      str_col << user.name
    end

    str_col.should eq "KasperMorten"
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
    map.delete(5).should === user
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
    map
    force_garbage_collection

    #Test each-method.
    count = 0
    map.each_key do |key|
      count += 1
    end

    count.should eq 1
    map.valid?(5).should eq true
    map.valid?(6).should eq false

    map.get(5).should === user
    map.get(6).should eq nil

    map.get!(5).should === user
    expect { map.get!(6) }.to raise_error(Wref::Recycled)
  end
end
