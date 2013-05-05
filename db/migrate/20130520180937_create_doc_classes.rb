class CreateDocClasses < ActiveRecord::Migration
  def change
    create_table :doc_classes do |t|
      t.references :doc_file, index: true
      t.string :name

      t.timestamps
    end
  end
end
