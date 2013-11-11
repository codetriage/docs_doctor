class DocClass < ActiveRecord::Base
  belongs_to :doc_file

  has_many :doc_methods,  dependent: :destroy
  has_many :doc_comments, dependent: :destroy
  include WhereOrCreate
end
