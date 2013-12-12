class CreateDocMethods < ActiveRecord::Migration
  def change
    create_table :doc_methods do |t|
      t.references :repo, index: true
      t.string  :name
      t.integer :line

      t.timestamps
    end
  end
end
