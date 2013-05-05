module DocsDoctor
  module Parsers
    module Ruby
      class Rdoc < ::DocsDoctor::Parser

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
            doc_file   = repo.doc_files.where_or_create(name: klass.top_level.name, path: File.expand_path(klass.top_level.relative_name))
            doc_class  = doc_file.doc_classes.where_or_create(name: klass.name)
            doc_class.doc_comments.create(comment: klass.comment.text) if klass.comment.respond_to?(:text) && klass.comment.text.present?
            klass.method_list.each do |method|
              doc_method = doc_class.doc_methods.where_or_create(name: method.name, line: method.line)
              doc_method.doc_comments.create(comment: method.comment.text) if method.comment.respond_to?(:text) && method.comment.text.present?
            end
          end
        end

        def process
          require 'rdoc'
          ## Ruby 4.0.0
          options        = RDoc::Options.new
          options.root   = Pathname.new('.').expand_path

          rdoc           = RDoc::RDoc.new
          rdoc.store     = RDoc::Store.new
          # rdoc.generator = RDoc::Generator::JsonIndex.new(RDoc::Generator::Markup, {})
          rdoc.options   = options


          foo = rdoc.parse_files(files)

          @classes.concat rdoc.store.all_classes_and_modules.sort # must call after parse_files
          @classes
        end
      end
    end
  end
end
