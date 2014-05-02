ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def fixture_path(name = "")
    path = Pathname.new(File.expand_path("../fixtures", __FILE__))
    path.join(name)
  end

  # Add more helper methods to be used by all tests here...
end

require 'parsers/yard_test'
require 'mocha/setup'

Q.queue_config.inline = true
