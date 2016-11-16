class UserMailer < ActionMailer::Base
  default from: "DocsDoctor <noreply@docsdoctor.org>"


  def daily_docs(options = {})
    @user       = options[:user]
    @write_docs = options[:write_docs]
    @read_docs  = options[:read_docs]
    count       = (@write_docs.try(:count) || 0) + (@read_docs.try(:count) || 0)
    subject     = "Check out #{count} Open Source #{"Doc".pluralize(count)}"
    mail(to: @user.email, subject: subject)
  end

  # general purpose mailer for sending out admin communications, only use from one off tasks
  def spam(user, message:, subject:)
    @user    = user
    @message = message
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: subject)
  end

  class Preview < MailView

    # Pull data from existing fixtures
    def send_spam
      user    = User.last
      message = "Hey, we just launched something big http://google.com"
      subject = "Big launch"
      ::UserMailer.spam(user, message: message, subject: subject)
    end


    # Pull data from existing fixtures
    def daily_docs
      user       = User.last


      write_docs = DocMethod.order("RANDOM()").missing_docs.first(rand(0..8))
      read_docs  = DocMethod.order("RANDOM()").with_docs.first(rand(0..8))

      write_docs = DocMethod.order("RANDOM()").first(rand(0..8)) if write_docs.blank?
      read_docs  = DocMethod.order("RANDOM()").first(rand(0..8)) if read_docs.blank?

      ::UserMailer.daily_docs(user: user, write_docs: write_docs, read_docs: read_docs)
    end

  end
end
