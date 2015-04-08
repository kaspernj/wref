require "spec_helper"

describe Wref::Implementations::IdClassUnique do
  it_should_behave_like "wref" unless RUBY_ENGINE == "jruby"
  it_should_behave_like "map" unless RUBY_ENGINE == "jruby"
end
