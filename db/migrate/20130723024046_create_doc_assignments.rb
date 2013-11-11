class CreateDocAssignments < ActiveRecord::Migration
  def change
    create_table :doc_assignments do |t|
      t.references :repo, index: true
      t.references :repo_subscription, index: true
      t.references :user, index: true
      t.references :doc_method
      t.references :doc_class

      t.timestamps
    end
  end
end
