namespace :schedule do
  desc "pulls in files from repos and adds them to the database"
  task process_repos: :environment do
    Repo.find_each do |repo|
      Repo.queue.populate_docs(repo.id)
    end
  end

  desc "Mark methods as 'inactive'"
  task do
    DocMethod.where(active: true).where("updated_at < '#{48.hours.ago}'").find_each do |m|
      m.active = false
      m.save
    end
  end

  desc "sends all users a method or class of a repo they are following"
  task user_send_doc: :environment do
    User.find_each do |user|
      User.queue.subscribe_docs(user.id)
    end
  end
end
