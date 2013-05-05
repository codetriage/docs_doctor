class CreateDocComments < ActiveRecord::Migration
  def change
    create_table :doc_comments do |t|
      t.references :doc_class, index: true
      t.references :doc_method, index: true
      t.text :comment

      t.timestamps
    end
  end
end
