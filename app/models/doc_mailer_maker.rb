class DocMailerMaker
  attr_accessor :user, :subs

  def initialize(user, subs)
    @user = user
    @subs = subs
    assign_docs
  end

  def assign_docs
    @docs ||= subs.flat_map do |sub|
      sub.unassigned_doc_methods.map { |doc| sub.assign_doc_method(doc); doc }
    end.compact
  end

  def docs
    @docs
  end

  def mail
    UserMailer.daily_docs(user: user, docs: docs)
  end

  def deliver
    mail.deliver
  end
end
