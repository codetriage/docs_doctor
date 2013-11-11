class DocMethod < ActiveRecord::Base
  belongs_to :doc_class
  delegate :doc_file, :to => :doc_class, :allow_nil => true
  delegate :repo, :to => :doc_file, :allow_nil => true

  has_many :doc_comments, dependent: :destroy
  include WhereOrCreate
  include ActiveRecord::CounterCache
end
