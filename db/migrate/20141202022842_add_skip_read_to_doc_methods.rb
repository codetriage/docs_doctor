class AddSkipReadToDocMethods < ActiveRecord::Migration
  def change
    add_column :doc_methods, :skip_read, :boolean, default: false
  end
end
