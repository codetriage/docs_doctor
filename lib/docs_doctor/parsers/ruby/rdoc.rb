module DocsDoctor
  module Parsers
    module Ruby
      class Rdoc < ::DocsDoctor::Parser
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

        def store(repo)
          classes.each do |klass|
            doc_file   = repo.doc_files.where_or_create(name: klass.top_level.name, path: relative_path(klass.top_level.relative_name))
            next unless doc_file
            doc_class  = doc_file.doc_classes.where_or_create(name: klass.name, line: klass.line)
            doc_class.doc_comments.create(comment: klass.comment.text) if klass.comment.respond_to?(:text) && klass.comment.text.present?
            klass.method_list.each do |method|
              doc_method = doc_class.doc_methods.where_or_create(name: method.name, line: method.line)
              doc_method.doc_comments.create(comment: method.comment.text) if method.comment.respond_to?(:text) && method.comment.text.present?
            end
          end
        end

        def root_path
          Pathname.new(base_path).expand_path
        end

        # convert "../rails/foo.rb" => /foo".rb
        def relative_path(path)
          path_array = path.split('/').select {|x| x != ".."}
          path_array.shift
          path_array.join('/')
        end

        def process
          require 'rdoc'
          ## Ruby 4.0.0
          rdoc            = RDoc::RDoc.new
          rdoc.store      = RDoc::Store.new
          rdoc.options    = RDoc::Options.new.tap do |options|
                              options.root = root_path
                            end

          rdoc.parse_files(files)

          @classes.concat rdoc.store.all_classes_and_modules.sort # must call after parse_files
          @classes
        end
      end
    end
  end
end
