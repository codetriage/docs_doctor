class AddActiveToDocMethods < ActiveRecord::Migration
  def change
    add_column :doc_methods, :active, :boolean, default: true
  end
end
