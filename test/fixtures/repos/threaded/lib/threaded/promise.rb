module Threaded
  class Promise
    class NoJobError < StandardError
      def initialize
        super "No job present for #{self.inspect}"
      end
    end

    attr_reader :has_run; alias :has_run? :has_run
    attr_reader :running; alias :running? :running
    attr_reader :error

    def initialize(&job)
      raise "Must supply a job" unless job
      @mutex   = Mutex.new
      @has_run = false
      @running = false
      @result  = nil
      @error   = nil
      @job     = job
    end

    def later
      Threaded.enqueue(self)
      self
    end

    def call
      @mutex.synchronize do
        return true if running? || has_run?
        begin
          raise NoJobError unless @job
          @running = true
          @result  = @job.call
        rescue Exception => error
          @error   = error
        ensure
          @stdout = Thread.current[:stdout].dup if Thread.current[:stdout]
          Thread.current[:stdout] = nil
          @has_run = true
        end
      end
    end

    def now
      wait_for_it!
      raise error, error.message, error.backtrace if error
      puts @stdout.string if @stdout
      @result
    end
    alias :join  :now
    alias :value :now

    private

    def wait_for_it!
      return true if has_run?

      if running?
        @mutex.synchronize {} # waits for lock to be released
      else
        call
      end
    end
  end
end
