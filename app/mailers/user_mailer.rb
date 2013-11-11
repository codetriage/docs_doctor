class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def daily_docs(options = {})
    @user = options[:user]
    @docs = options[:docs]
    mail(:to => @user.email, subject: "Check out #{@docs.count} Open Source #{"Doc".pluralize(@docs.count)}")
  #   do |format|
  #     format.md { render 'daily_docs' }
  #   end
  end


  class Preview < MailView
    # Pull data from existing fixtures
    def daily_docs
      user    = User.last
      docs    = DocMethod.last(rand(6) + 1)
      ::UserMailer.daily_docs(user: user, docs: docs)
    end

  end
end
