class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def daily_docs(options = {})
    @user       = options[:user]
    @write_docs = options[:write_docs]
    @read_docs  = options[:read_docs]
    puts options.inspect
    count       = (@write_docs.try(:count) || 0) + (@read_docs.try(:count) || 0)
    subject     = "Check out #{count} Open Source #{"Doc".pluralize(count)}"
    mail(to: @user.email, subject: subject)
  end


  class Preview < MailView
    # Pull data from existing fixtures
    def daily_docs
      user       = User.last
      write_docs = DocMethod.order("RANDOM()").first(rand(0..8))
      read_docs  = DocMethod.order("RANDOM()").first(rand(0..8))

      ::UserMailer.daily_docs(user: user, write_docs: write_docs, read_docs: read_docs)
    end

  end
end