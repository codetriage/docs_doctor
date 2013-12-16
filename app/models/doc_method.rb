class DocMethod < ActiveRecord::Base
  belongs_to :repo
  has_many   :doc_comments, dependent: :destroy

  include ActiveRecord::CounterCache

  def file
    absolute, match, relative = read_attribute(:file).partition(/(\/|^)#{repo.name}\//)
    return relative
  end
end
