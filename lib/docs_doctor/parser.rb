module DocsDoctor
  class Parser
    attr_accessor :files, :base_path

    def initialize(base = nil)
      @classes ||=[]
      if @base_path = base
        process_base!(base)
        add_files(base)
      end
    end

    # "foo/"   => expands to full directory
    # "foo"    => expands to full directory
    # "foo/*"  => glob provided, use explicit input
    # "foo.rb" => exact file provided use explicit input
    def process_base!(base)
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


    def classes
      if @classes.empty?
        process
        @classes
      else
        @classes
      end
    end

    def root_path
      Pathname.new(base_path).expand_path
    end
  end
end