class RepoSubscription < ActiveRecord::Base
  validates :repo_id, :uniqueness => {:scope => :user_id}

  belongs_to :repo
  belongs_to :user
  has_many   :doc_assignments

  validates :email_limit, numericality: {less_than: 21, greater_than: 0}

  def self.ready_for_docs
    where("last_sent_at is null or last_sent_at < ?", 23.hours.ago)
  end

  def ready_for_next?
    return true if last_sent_at.blank?
    last_sent_at < 24.hours.ago
  end

  def not_ready_for_next?
    !ready_for_next?
  end

  def pre_assigned_doc_method_ids
    self.doc_methods.map(&:id) + [-1]
  end

  def unassigned_read_doc_methods(limit = self.email_limit)
    repo.methods_with_docs.
         where("doc_methods.id not in (?)", pre_assigned_doc_method_ids).
         order("random()").
         limit(limit)
  end

  def unassigned_write_doc_methods(limit = self.email_limit)
    doc_method_ids = self.doc_methods.map(&:id) + [-1]
    repo.methods_missing_docs.
         where("doc_methods.id not in (?)", pre_assigned_doc_method_ids).
         where(skip_write: false).
         order("random()").
         limit(limit)
  end

  def doc_methods
    DocMethod.where(id: doc_assignments.map(&:doc_method_id))
  end
end
