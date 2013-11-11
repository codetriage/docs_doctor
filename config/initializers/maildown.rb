

# puts klass.default_formats
# puts klass.instance_methods

# module ActionView
#   module Template::Handlers
#     class Md
#       def call(template)
#         puts "foo"
#       end
#     end
#   end
# end

# ActionView::Template::Types::Type.register :md

# ActionMailer::Base.send(:include, Maildown::Md)




user = User.last
docs = DocMethod.last(rand(6) + 1)
puts ::UserMailer.daily_docs(user: user, docs: docs).body