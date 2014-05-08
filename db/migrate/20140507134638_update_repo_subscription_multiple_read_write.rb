class UpdateRepoSubscriptionMultipleReadWrite < ActiveRecord::Migration
  def change
    add_column :repo_subscriptions, :write_limit, :integer
    add_column :repo_subscriptions, :read_limit,  :integer
  end
end
