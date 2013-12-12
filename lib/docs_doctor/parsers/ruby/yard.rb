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
        #
        # YARD::CodeObjects::MethodObject
        # YARD::CodeObjects::MethodObject
        # YARD::CodeObjects::MethodObject
        # YARD::CodeObjects::MethodObject
        # YARD::CodeObjects::MethodObject
        def store_entity(obj, repo)
          object = case obj
          when YARD::CodeObjects::ModuleObject, YARD::CodeObjects::ClassObject
            repo.doc_classes.where(
                name: obj.name,
                path: obj.path
              ).first_or_create
          when YARD::CodeObjects::MethodObject
            repo.doc_methods.where(
                name: obj.name,
                path: obj.path
              ).first_or_create
          when YARD::CodeObjects::ConstantObject
            return true
          else
            puts "Unknown YARD object: #{obj.inspect}"
            return true
          end
          object.doc_comments.where(comment: obj.docstring).first_or_create
          object.update_attributes(line: obj.line, file: obj.file)
        end


        def process
          require 'yard'
          YARD.parse(files)
          @yard_objects = YARD::Registry.all
        end
      end
    end
  end
end


