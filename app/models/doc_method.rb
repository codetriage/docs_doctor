class DocMethod < ActiveRecord::Base
  belongs_to :doc_class
  has_many :doc_comments
  include WhereOrCreate
  include ActiveRecord::CounterCache
end
