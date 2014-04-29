module DocsDoctor
  module Parsers
    module Ruby
      class Yard < ::DocsDoctor::Parser

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
            repo.doc_methods.where(
                name: name,
                path: path
              ).first_or_create
          when YARD::CodeObjects::ConstantObject
            return true
          else
            puts "Unknown YARD object: #{obj.inspect}"
            return true
          end

          object.doc_comments.where(comment: docstring).first_or_create if docstring.present?
          object.update_attributes(line: line, file: file)
        end


        # http://rubydoc.org/gems/yard/YARD/Parser/SourceParser#parse-class_method
        def process
          require 'yard'
          YARD.parse(files, ["(^|\/)test\/.*" , "(^|\/)spec\/.*"])
          @yard_objects = YARD::Registry.all
        end
      end
    end
  end
end


