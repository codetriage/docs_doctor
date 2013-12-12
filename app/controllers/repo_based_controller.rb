class RepoBasedController < ApplicationController
  protected

    def name_from_params(options)
      [options[:name], options[:format]].compact.join('.')
    end

    def find_repo(options)
      Repo.where(full_name: options[:full_name]).first!
    end
end
