require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'User#subscribe_docs' do
    user  = users(:mockstar)
    repo  = repos(:rails_rails)

    doc_method      = repo.doc_methods.new
    doc_method.name = "retry"
    doc_method.path = "Enumerable#retry"
    doc_method.file = "/var/folders/0f/dkwlpq9x1nbghzpqj3zxy9kc0000gn/T/d20140430-34657-tx1epf/rrrretry/lib/rrrretry.rb"
    assert doc_method.save, "Expected method to save, but did not: #{doc_method.errors.inspect}"

    repo_sub = user.repo_subscriptions.new
    repo_sub.repo  = repo
    repo_sub.read  = true
    repo_sub.write = true
    repo_sub.write_limit = 1
    repo_sub.read_limit  = 1
    assert repo_sub.save, "Expected subscription to save, but did not: #{repo_sub.errors.inspect}"

    assert_difference("User.find(#{user.id}).doc_assignments.count", 1) do
      DocMethod.any_instance.stubs(:valid_for_user?).returns(true)
      User.queue.subscribe_docs(user.id)
    end
  end
end

