require "spec_helper"

describe Wref::Implementations::WeakRef do
  it_should_behave_like "wref"
  it_should_behave_like "map"
end
