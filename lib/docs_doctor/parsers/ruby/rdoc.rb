module DocsDoctor
  module Parsers
    module Ruby
      class Rdoc < ::DocsDoctor::Parser
        attr_accessor :files, :base_path

        def store(repo)
          classes.each do |klass|
            doc_file  = repo.doc_files.where(
                          name: klass.top_level.name,
                          path: relative_path(klass.top_level.relative_name)
                        ).first_or_create
            next unless doc_file

            doc_class = doc_file.doc_classes.where(
                            name: klass.name,
                            line: klass.line
                          ).first_or_create

            if klass.comment.respond_to?(:text) && klass.comment.text.present?
              doc_class.doc_comments.where(comment: klass.comment.text).first_or_create
            end

            klass.method_list.each do |method|
              doc_method  = doc_class.doc_methods.where(
                              name: method.name,
                              line: method.line
                            ).first_or_create

              if klass.comment.respond_to?(:text) && klass.comment.text.present?
                doc_method.doc_comments.where(comment: method.comment.text).first_or_create
              end
            end
          end
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
