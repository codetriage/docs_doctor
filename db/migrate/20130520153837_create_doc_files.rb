class CreateDocFiles < ActiveRecord::Migration
  def change
    create_table :doc_files do |t|
      t.references :repo, index: true
      t.string :name
      t.string :path

      t.timestamps
    end
  end
end
