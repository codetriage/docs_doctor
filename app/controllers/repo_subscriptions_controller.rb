class RepoSubscriptionsController < ApplicationController
  def create
    repo = Repo.find(repo_subscription_params[:repo_id])
    @repo_subscription = current_user.repo_subscriptions.where(repo: repo).first_or_create
    @repo_subscription.read  = repo_subscription_params[:read]  if repo_subscription_params.key?(:read)
    @repo_subscription.write = repo_subscription_params[:write] if repo_subscription_params.key?(:write)
    if @repo_subscription.save
      # @repo_subscription.send_triage_email!
      redirect_to :back, notice: I18n.t('repo_subscriptions.subscribed')
    else
      flash[:error] = "Something went wrong #{@repo_subscription.errors.full_messages}"
      redirect_to :back
    end
  end

  def destroy
    @repo_sub = current_user.repo_subscriptions.find params[:id]
    @repo_sub.destroy
    redirect_to :back, notice: "Unsubscribed"
  end

  private

    def repo_subscription_params
      params.require(:repo_subscription).permit(
        :repo_id,
        :email_limit,
        :read,
        :write
        )
    end
end