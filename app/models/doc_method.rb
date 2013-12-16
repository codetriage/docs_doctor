class DocMethod < ActiveRecord::Base
  belongs_to :repo
  has_many   :doc_comments, dependent: :destroy

  validates :file, :name, :path, presence: true

  include ActiveRecord::CounterCache

  def file
    return nil if read_attribute(:file).blank?
    absolute, match, relative = read_attribute(:file).partition(/(\/|^)#{repo.name}\//)
    return relative
  end
end
