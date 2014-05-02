module Threaded
  class Worker
    POISON = "poison"
    attr_reader :queue, :logger, :thread

    def initialize(queue, options = {})
      @queue   = queue
      @logger  = options[:logger]  || Threaded.logger
      @thread  = create_thread
    end

    def poison
      @queue.enq(POISON)
    end

    def start
      puts "start is deprecated, thread is started when worker created"
    end

    def dead?
      !alive?
    end

    def alive?
      thread.alive?
    end

    def join
      thread.join
    end

    private
    def create_thread
      Thread.new {
        logger.debug("Threaded In Memory Queue Worker '#{object_id}' ready")
        loop do
          payload   = queue.pop
          job, json = *payload
          break if payload == POISON
          job.call(*json)
        end
        logger.debug("Threaded In Memory Queue Worker '#{object_id}' stopped")
      }
    end
  end
end

