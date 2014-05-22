module DocsDoctor
  class Parser
    attr_accessor :files, :base_path

    def initialize(base)
      @classes ||=[]
      @base_path = base
      self.files = []
      self.files << process_base!(base)
    end

    # "foo/"   => expands to full directory
    # "foo"    => expands to full directory
    # "foo/*"  => glob provided, use explicit input
    # "foo.rb" => exact file provided use explicit input
    def process_base!(base)
      base = base.to_s
      return base if base.match(/\.rb$/)
      return base if base.include?("*")
      base << "/" unless base.match(/\/$/)
      base << "**/*.rb"
      base
    end

    def add_files(*files)
      self.files ||= []
      self.files.concat Dir.glob(files)
      files
    end
    alias :add_file :add_files

    def root_path
      root_path = Pathname.new(base_path).expand_path
      if root_path.to_s.match(/\.rb+$/)
        root_path.dirname
      else
        root_path
      end
    end
  end
end
