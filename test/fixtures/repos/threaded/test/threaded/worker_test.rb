require 'test_helper'

class WorkerTest < Test::Unit::TestCase
  def setup
    @worker = Threaded::Worker.new(Queue.new, timeout: 1)
  end

  def teardown

  end

  def test_calls_contents_of_blocks
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    job = Proc.new {|x| Dummy.process(x) }

    @worker.queue << [job, 1]
    @worker.queue << [job, 2]
    @worker.poison
    @worker.join
  end

  def test_calls_context_of_klass
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    job = Class.new do
      def self.call(num)
        Dummy.process(num)
      end
    end

    @worker.queue << [job, 1]
    @worker.queue << [job, 2]
    @worker.poison
    @worker.join
  end
end
