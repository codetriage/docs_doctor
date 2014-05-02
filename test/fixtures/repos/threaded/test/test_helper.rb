Bundler.require

require 'threaded'
require 'test/unit'
require "mocha/setup"


module Dummy
end

Threaded.logger.level = Logger::WARN