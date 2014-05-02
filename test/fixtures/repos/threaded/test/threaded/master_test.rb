require 'test_helper'

class MasterTest < Test::Unit::TestCase

  def test_non_explicit_thread_start
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    master = Threaded::Master.new(size: 1)

    job = Proc.new {|x| Dummy.process(x) }

    master.enqueue(job, 1)
    master.enqueue(job, 2)
    master.stop
  end

  def test_creates_up_to_max_workers
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    master = Threaded::Master.new(size: 2)

    job = Proc.new {|x| sleep 0.5; Dummy.process(x) }

    master.enqueue(job, 1)
    master.enqueue(job, 2)

    assert_equal 2, master.size

    Dummy.expects(:process).with(3).times(3)
    master.enqueue(job, 3)
    master.enqueue(job, 3)
    master.enqueue(job, 3)

    assert_equal 2, master.size
    master.stop
  end

  def test_thread_worker_creation
    size   = 1
    master = Threaded::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop

    size   = 3
    master = Threaded::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop

    size   = 6
    master = Threaded::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop

    size   = 16
    master = Threaded::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop
  end

  def test_calls_contents_of_blocks
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    master = Threaded::Master.new(size: 1)
    master.start

    job = Proc.new {|x| Dummy.process(x) }

    master.enqueue(job, 1)
    master.enqueue(job, 2)
    master.stop
  end

  def test_calls_context_of_klass
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    job = Class.new do
      def self.call(num)
        Dummy.process(num)
      end
    end

    master = Threaded::Master.new(size: 1)
    master.start
    master.enqueue(job, 1)
    master.enqueue(job, 2)
    master.stop
  end
end
