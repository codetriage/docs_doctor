class RepoSubscription < ActiveRecord::Base
  include ResqueDef

  validates :repo_id, :uniqueness => {:scope => :user_id}

  belongs_to :repo
  belongs_to :user
  has_many   :issue_assignments
  has_many   :issues, through: :issue_assignments

  validates :email_limit, numericality: {less_than: 21, greater_than: 0}

  def self.ready_for_triage
    where("last_sent_at is null or last_sent_at < ?", 23.hours.ago)
  end

  def ready_for_next?
    return true if last_sent_at.blank?
    last_sent_at < 24.hours.ago
  end

  def wait?
    !ready_for_next?
  end
end

