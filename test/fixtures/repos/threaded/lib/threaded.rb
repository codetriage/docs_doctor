require 'thread'
require 'timeout'
require 'logger'
require 'stringio'

require 'threaded/version'

module Threaded
  STOP_TIMEOUT = 10 # seconds
  extend self

  @mutex = Mutex.new

  attr_reader :logger, :size, :inline, :sync_promise_io
  alias :sync_promise_io? :sync_promise_io
  alias :inline? :inline

  def inline=(inline)
    @mutex.synchronize { @inline = inline }
  end

  def logger=(logger)
    @mutex.synchronize { @logger = logger }
  end

  def size=(size)
    @mutex.synchronize { @size = size }
  end

  def sync_promise_io=(sync_promise_io)
    @mutex.synchronize { @sync_promise_io = sync_promise_io }
  end
  @sync_promise_io = true

  def start(options = {})
    raise "Queue is already started, must configure queue before starting" if options.any? && started?
    options.each do |k, v|
      self.send(k, v)
    end
    self.master.start
    return self
  end

  def master
    @mutex.synchronize do
      return @master if @master
      @master = Master.new(logger: self.logger,
                           size:   self.size)
    end
    @master
  end
  alias :master= :master


  def configure(&block)
    raise "Queue is already started, must configure queue before starting" if started?
    yield self
  end
  alias :config  :configure

  def started?
    !stopped?
  end

  def stopped?
    master.stopping?
  end

  def later(&block)
    job = if sync_promise_io?
      Proc.new {
        Thread.current[:stdout] = StringIO.new
        block.call
      }
    else
      block
    end
    Threaded::Promise.new(&job).later
  end

  def enqueue(job, *args)
    if inline?
      job.call(*args)
    else
      master.enqueue(job, *args)
    end
    return true
  end

  def stop(timeout = STOP_TIMEOUT)
    return true unless master
    master.stop(timeout)
    return true
  end
end

Threaded.logger       = Logger.new(STDOUT)
Threaded.logger.level = Logger::INFO


require 'threaded/errors'
require 'threaded/ext/stdout'
require 'threaded/worker'
require 'threaded/master'
require 'threaded/promise'
