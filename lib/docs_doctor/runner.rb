require [__dir__, "parsers", "ruby", "rdoc.rb"].join('/')

module DocsDoctor
  class Runner

    def initialize(*foo)
      # do nothing
    end

    def parser
      DocsDoctor::Parsers::Ruby::Rdoc_4_0_0.new
    end
  end
end