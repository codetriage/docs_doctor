module DocsDoctor
  module Parsers
    module Ruby
      class Yard < ::DocsDoctor::Parser
        # we don't want any files in /test or /spec unless it's
        # for testing this codebase
        DEFAULT_EXCLUDE = ["(^|\/)test\/(?!fixtures)" , "(^|\/)spec\/(?!fixtures)"]

        attr_reader :yard_objects

        def initialize(base = nil)
          @yard_objects = []
          super
        end

        def store(repo)
          @yard_objects.each do |obj|
            store_entity(obj, repo)
          end
        end

        # YARD::CodeObjects::ModuleObject
        # YARD::CodeObjects::ClassObject
        # YARD::CodeObjects::ConstantObject
        # YARD::CodeObjects::MethodObject
        def store_entity(obj, repo)
          docstring = obj.docstring
          name      = obj.name
          path      = obj.path
          line      = obj.line
          file      = obj.file

          if name.blank? || path.blank? || line.blank? || file.blank?
            puts "Could not store YARD object, missing one or more properties: #{obj.inspect}"
            return false
          end

          object = case obj
          when YARD::CodeObjects::ModuleObject, YARD::CodeObjects::ClassObject
            repo.doc_classes.where(
                name: name,
                path: path
              ).first_or_create
          when YARD::CodeObjects::MethodObject
            # attr_writer, attr_reader don't need docs
            # document original method instead
            # don't document initialize
            skip_write  = obj.is_attribute? || obj.is_alias? || (obj.respond_to?(:is_constructor?) && obj.is_constructor?)

            repo.doc_methods.where(
                name: name,
                path: path,
                skip_write: skip_write
              ).first_or_create
          when YARD::CodeObjects::ConstantObject
            return true
          else
            puts "Unknown YARD object: #{obj.inspect}"
            return true
          end

          object.update_attributes(line: line, file: file)
          object.doc_comments.where(comment: docstring).first_or_create if docstring.present?
        end


        # http://rubydoc.org/gems/yard/YARD/Parser/SourceParser#parse-class_method
        def process(exclude = DEFAULT_EXCLUDE)
          require 'yard'
          YARD.parse(files, exclude)
          @yard_objects = YARD::Registry.all
        end
      end
    end
  end
end


