module Threaded
  class NoWorkersError < RuntimeError; end

  class WorkerNotStarted < RuntimeError; end
end
