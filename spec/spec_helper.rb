$LOAD_PATH.unshift(File.join(__dir__, "..", "lib"))
$LOAD_PATH.unshift(__dir__)
require "rspec"
require "wref"
require "weakling" if RUBY_ENGINE == "jruby"
require "ref"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
