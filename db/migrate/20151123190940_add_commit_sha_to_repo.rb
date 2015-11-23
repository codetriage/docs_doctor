class AddCommitShaToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :commit_sha, :string
  end
end
