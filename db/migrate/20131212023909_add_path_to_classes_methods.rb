class AddPathToClassesMethods < ActiveRecord::Migration
  def change
    add_column :doc_classes, :path,  :string
    add_column :doc_classes, :file,  :string

    add_column :doc_methods, :path,  :string
    add_column :doc_methods, :file,  :string
  end
end
