require "spec_helper"

describe Wref do
  let(:gc) do
    GC.enable
    GC.start

    1000.times do
      some_str = "#{Digest::MD5.hexdigest(Time.now.to_f.to_s)}".clone
      some_str = nil
    end

    GC.enable
    GC.start
  end

  describe "#alive?" do
    it "is true when ref exists" do
      str = "Test"
      ref = Wref.new(str)
      ref.alive?.should eq true
    end

    it "is false when ref has been removed" do
      str = "Test"
      ref = Wref.new(str)
      str = nil

      str2 = "Test 2"
      ref2 = Wref.new(str2)
      ref2 = nil

      gc

      ref.alive?.should eq false
    end
  end

  it "#get" do
    str = "Test"
    ref = Wref.new(str)
    ref.get.should === str
  end
end