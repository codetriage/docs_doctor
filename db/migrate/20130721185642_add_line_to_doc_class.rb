class AddLineToDocClass < ActiveRecord::Migration
  def change
    add_column :doc_classes, :line, :integer
  end
end
