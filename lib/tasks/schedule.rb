namespace :schedule do
  desc "pulls in files from repos and adds them to the database"
  task :process_repos do
    Repo.find_each do |repo|
      Repo.background_process(repo.id)
    end
  end

  # desc "sends all users an undocumented method or class of a repo they are following"
  # task :user_send_doc do
  #   User.find_each do |user|
  #     user.subscribe_docs!
  #   end
  # end
end
