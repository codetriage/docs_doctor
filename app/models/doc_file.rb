class DocFile < ActiveRecord::Base
  belongs_to :repo
  has_many :doc_classes, dependent: :destroy
  has_many :doc_methods, through: :doc_classes, dependent: :destroy
  validate :not_excluded?, on: :create

  include WhereOrCreate

  def path
    Pathname.new(read_attribute(:path))
  end

  def not_excluded?
    return true unless excluded?
    errors.add(:path, "this path is excluded from the repo with regex: /#{repo.excluded}/")
  end

  def excluded?
    return false if repo.excluded.blank?
    self.path.to_s.match(/#{repo.excluded}/)
  end
end
