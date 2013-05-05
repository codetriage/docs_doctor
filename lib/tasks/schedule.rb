namespace :schedule do
  desc "pulls in files from repos and adds them to the database"
  task :process_projects do
    DocProj.find_each do |proj|
      proj.process!
    end
  end

  desc "sends all users an undocumented method or class of a repo they are following"
  task :user_send_doc do
    User.find_each do |user|
      user.subscribe_docs!
    end
  end
end
