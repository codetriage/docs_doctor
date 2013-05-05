class RepoSubscriptions < ActiveRecord::Migration
  def change
    create_table :repo_subscriptions do |t|
      t.datetime "last_sent_at"
      t.integer  "email_limit",  :default => 1
      t.references  :user, index: true
      t.references  :repo, index: true

      t.timestamps
    end
  end
end
