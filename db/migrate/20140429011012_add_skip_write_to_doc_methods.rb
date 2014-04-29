class AddSkipWriteToDocMethods < ActiveRecord::Migration
  def change
    add_column :doc_methods, :skip_write, :boolean, default: false
  end
end
