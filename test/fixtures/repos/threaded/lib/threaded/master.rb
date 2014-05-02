module Threaded
  class Master
    DEFAULT_TIMEOUT = 10 # seconds
    DEFAULT_SIZE    = 16
    attr_reader :workers, :logger

    def initialize(options = {})
      @queue    = Queue.new
      @mutex    = Mutex.new
      @stopping = false
      @max      = options[:size]     || DEFAULT_SIZE
      @logger   = options[:logger]   || Threaded.logger
      @workers  = []
    end

    def enqueue(job, *json)
      @queue.enq([job, json])

      new_worker if needs_workers? && @queue.size > 0
      raise NoWorkersError unless workers.detect {|w| w.alive? }
      return true
    end

    def start
      new_workers(@max, true)
      return self
    end

    def stop(timeout = DEFAULT_TIMEOUT)
      @mutex.synchronize do
        @stopping = true
        workers.each {|w| w.poison }
        timeout(timeout, "waiting for workers to stop") do
          while workers.any?
            workers.reject! {|w| w.join if w.dead? }
          end
        end
      end
      return self
    end

    def size
      @workers.size
    end

    def stopping?
      @stopping
    end

    private

    def timeout(timeout, message = "", &block)
      ::Timeout.timeout(timeout) do
        yield
      end
    rescue ::Timeout::Error
      logger.error("Took longer than #{timeout} to #{message.inspect}")
    end

    def needs_workers?
      size < @max
    end

    def max_workers?
      !needs_workers?
    end

    def new_worker(num = 1, force_start = false)
      @mutex.synchronize do
        @stopping = false if force_start
        return false      if stopping?
        num.times do
          next if max_workers?
          @workers << Worker.new(@queue)
        end
      end
    end
    alias :new_workers :new_worker
  end
end
