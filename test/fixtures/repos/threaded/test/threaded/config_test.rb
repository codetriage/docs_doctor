require 'test_helper'
require 'stringio'

class ConfigTest < Test::Unit::TestCase

  def setup
    Threaded.stop
  end

  def teardown
    Threaded.start
  end

  def test_config_works
    fake_out = StringIO.new
    logger   = Logger.new(fake_out)
    size     = rand(1..99)

    Threaded.configure do |config|
      config.size    = size
      config.logger  = logger
    end

    Threaded.start

    assert_equal size,    Threaded.size
    assert_equal logger,  Threaded.logger
  end

  def test_config_cannot_call_after_start
    Threaded.start
    assert_raise(RuntimeError) do
      Threaded.configure do |config|
        config.size    = size
        config.logger  = logger
      end
    end
  end
end
