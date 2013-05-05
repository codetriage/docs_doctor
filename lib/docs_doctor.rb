require 'active_support/core_ext/object/blank'


module DocsDoctor
end

require 'docs_doctor/loader'
require 'docs_doctor/parser'
require 'docs_doctor/runner'

Dir["#{__dir__}/docs_doctor/loader/*.rb"].each do |file|
  require file
end

require 'docs_doctor/parsers/ruby/rdoc'


# DocProj has many DocFiles
# DocFile has many DocClass(es)
# DocClass has many DocMethods

# DocMethod has many DocComments
# DocClass has many DocComments

# proj = DocProj.where(name: 'rails').first || DocProj.create(name: 'rails')
# parser.go do |klass|
#   puts klass.inspect

# end


  # klass.each_section do |section, constants, attributes|
  #   klass.methods_by_type(section).each do |type, visibilities|
  #     visibilities.each do |visibility, methods|
  #       methods.each do |method|
  #         yield
  #         puts "=="
  #         @methods << @method = method
  #         puts method
  #         puts method.comment.text
  #         puts method.documented?
  #         puts method.file_name
  #       end
  #     end
  #   end
  # end

# parser = DocsDoctor::Parser.new('ruby/rdoc', '4.0.0')
# parser.add_files("/Users/schneems/Documents/projects/rails/activesupport/lib/active_support/core_ext/string/strip.rb")
# parser.go!

# parser.files.each do |file|
#   file.classes.each do |klass|
#     klass.methods.each do |method|

#     end
#   end
# end


# parser.methods
# parser.class_modules


# ## Needed Classes
# DocsDoctor::File
# DocsDoctor::ClassModule
# DocsDoctor::Method


# DocsDoctor::Parser
# - add_files
# - go!
# - files
# - class_modules
# - methods
