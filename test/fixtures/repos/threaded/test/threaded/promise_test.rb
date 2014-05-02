require 'test_helper'

class PromiseTest < Test::Unit::TestCase

  def test_promise_interface
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    promise1 = Threaded.later do
      Dummy.process(1)
    end

    promise2 = Threaded.later do
      Dummy.process(2)
    end

    promise1.value
    promise2.value
  end


  def test_stdout_stdio
    value = "foo"
    promise = Threaded.later do
      puts value
    end
    promise.join
    assert_match value, promise.instance_variable_get("@stdout").string
  end

  def test_no_sync_stdio
    Threaded.sync_promise_io = false

    value = "foo"
    promise = Threaded.later do
      puts value
    end
    promise.join
    assert_equal nil, promise.instance_variable_get("@stdout")
  ensure
    Threaded.sync_promise_io = true
  end

  class Dummy
    def later(num)
      Threaded.later do
        process(num)
      end
    end

    def process(num)
      Dummy.process(num)
    end
  end

  def test_scope
    Dummy.expects(:process).with(1).once
    Dummy.new.later(1).value
  end
end
