class RepoSubscription < ActiveRecord::Base
  include ResqueDef

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

  def unassigned_doc_methods(limit = self.email_limit)
    repo.methods_missing_docs.where("doc_methods.id not in (?)", self.doc_methods.map(&:id) + [-1]).order("random()").limit(limit)
  end

  def assign_doc_method(doc)
    return if doc.blank?
    return doc if self.doc_assignments.where(doc_method_id: doc.id).first
    ActiveRecord::Base.transaction do
      self.doc_assignments.create!(doc_method_id: doc.id)
      self.update_attributes(last_sent_at: Time.now)
    end
    doc
  end

  def doc_methods
    DocMethod.where(id: doc_assignments.map(&:doc_method_id))
  end
end

