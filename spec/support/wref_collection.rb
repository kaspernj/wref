shared_examples_for "wref" do
  include GarbageCollectorHelper

  let(:implementation) do
    class_name = described_class.name

    if match = class_name.match(/::([A-z]+)$/)
      impl = match[1].to_sym if match[1] != "Map"
    end

    return impl
  end

  let(:user) { User.new("Kasper") }
  let(:user_ref) { Wref.new(user, impl: implementation) }

  def ref_in_danger
    return Wref.new(User.new("Morten"), impl: implementation)
  end

  it "#implementation" do
    user_ref.implementation.should eq implementation if described_class != Wref
  end

  it "#weak_ref" do
    user_ref.weak_ref.should be_a described_class if described_class != Wref
  end

  describe "#alive?" do
    it "is true when ref exists" do
      user_ref.alive?.should eq true
    end

    it "is false when ref has been removed" do
      ref = ref_in_danger
      force_garbage_collection
      ref.alive?.should eq false
    end
  end

  describe "#get" do
    it "#get" do
      user_ref.get.name.should eq "Kasper"
      ref2 = ref_in_danger

      force_garbage_collection

      user_ref.get.should === user
      ref2.get.should eq nil
    end

    it "returns the correct content initialy" do
      ref_in_danger.get.name.should eq "Morten"
    end
  end

  it "#get!" do
    ref = user_ref
    ref.get!.should === user

    ref2 = ref_in_danger

    force_garbage_collection

    ref.get!.should === user
    expect { ref2.get! }.to raise_error Wref::Recycled
  end
end
