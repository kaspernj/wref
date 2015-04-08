require "spec_helper"

describe Wref::Implementations::Weakling do
  it_should_behave_like "wref" if RUBY_ENGINE == "jruby"
  it_should_behave_like "map" if RUBY_ENGINE == "jruby"
end
