class IssueAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  def create
    repo_sub = current_user.repo_subscriptions.find(params[:id])
    DocMailerMaker.new(current_user, [repo_sub]).deliver
    redirect_to :back, notice: 'You will receive an email with more docs shortly'
  end
end
