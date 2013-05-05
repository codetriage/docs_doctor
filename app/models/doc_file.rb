class DocFile < ActiveRecord::Base
  belongs_to :repo
  has_many :doc_classes
  has_many :doc_methods,  through: :doc_classes
  include WhereOrCreate
end
