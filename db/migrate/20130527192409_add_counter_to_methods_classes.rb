class AddCounterToMethodsClasses < ActiveRecord::Migration
  def change
    add_column :doc_classes, :doc_comments_count, :integer, :default => 0, :null => false
    add_column :doc_methods, :doc_comments_count, :integer, :default => 0, :null => false
  end
end
