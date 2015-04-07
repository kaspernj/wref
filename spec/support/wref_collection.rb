shared_examples_for "wref" do
  include GarbageCollectorHelper

  def ref_in_danger
    return described_class.new(Time.new.to_f.to_s)
  end

  describe "#alive?" do
    it "is true when ref exists" do
      str = "Test"
      ref = described_class.new(str)
      ref.alive?.should eq true
    end

    it "is false when ref has been removed" do
      str = "Test"
      ref = described_class.new(str)
      str = nil

      str2 = "Test 2"
      ref2 = ref_in_danger
      ref2 = nil

      force_garbage_collection

      ref.alive?.should eq false
    end
  end

  describe "#get" do
    it "#get" do
      str = "Test"

      ref = described_class.new(str)
      ref.get.should === str

      ref2 = ref_in_danger

      force_garbage_collection

      ref.get.should === str
      ref2.get.should eq nil
    end

    it "returns the correct content initialy" do
      ref_in_danger.get.should match /\A[\d\.]+\Z/
    end
  end

  it "#get!" do
    str = "Test"

    ref = described_class.new(str)
    ref.get!.should === str

    ref2 = described_class.new(Time.new.to_f.to_s)

    force_garbage_collection

    ref.get!.should === str
    expect { ref2.get! }.to raise_error Wref::Recycled
  end
end
