class DocClass < ActiveRecord::Base
  belongs_to :doc_files
  has_many :doc_methods
  has_many :doc_comments
  include WhereOrCreate
end
