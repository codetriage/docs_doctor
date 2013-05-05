module WhereOrCreate
 extend ActiveSupport::Concern

  module ClassMethods
    def where_or_create(options = {})
      self.where(options).first || self.create(options)
    end
  end
end
