class ReposController < RepoBasedController

  def index
    # TODO join and order by subscribers
    @repos = Repo.order(:name).page(params[:page]).per_page(params[:per_page]||50)
  end

  def new
    @repo = Repo.new(user_name: params[:user_name], name: name_from_params(params))

    if user_signed_in?
      @own_repos = Rails.cache.fetch("user/repos/#{current_user.id}", expires_in: 24.hours) do
        GitHubBub.get("/user/repos", token: current_user.token, type: "owner", per_page: '100').
          json_body.sort_by { |r| r.fetch("full_name").downcase }
      end

      @starred_repos = Rails.cache.fetch("users/starred/#{current_user.id}", expires_in: 24.hours) do
        GitHubBub.get("/user/starred", token: current_user.token).
          json_body.sort_by { |r| r.fetch("full_name").downcase }
      end

      @watched_repos = Rails.cache.fetch("users/subscriptions/#{current_user.id}", expires_in: 24.hours) do
        GitHubBub.get("/user/subscriptions", token: current_user.token).
          json_body.sort_by { |r| r.fetch("full_name").downcase }
      end
    end
  end

  def show
    @repo        = Repo.where(full_name: params[:full_name]).first!
    @repo_sub    = current_user.repo_subscriptions.where(id: @repo.id).first if current_user
    @subscribers = @repo.subscribers.is_public.limit(27)
  end

  def create
    params = { name:      repo_params[:name].downcase.strip,
               user_name: repo_params[:user_name].downcase.strip }
    @repo  = Repo.where(params).first_or_create(language: "pending")

    if @repo.save
      flash[:notice] = "Added #{@repo.to_param} for doc doctoring"
      repo_sub  = RepoSubscription.create(
                    repo:  @repo,
                    user:  current_user,
                    write: true)
      # repo_sub.send_triage_email! TODO: send email on subscription

      redirect_to @repo
    else
      redirect_to :new, params
    end
  end

  def edit
    @repo = find_repo(params)
    redirect_to root_path, :notice => "You cannot edit this repo" unless current_user.able_to_edit_repo?(@repo)
  end

  def update
    @repo = find_repo(params)
    if @repo.update_attributes(repo_params)
      redirect_to @repo, :notice => "Repo updated"
    else
      render :edit
    end
  end

  private

    def repo_params
      params.require(:repo).permit(
        :name,
        :user_name,
        :issues_count,
        :language,
        :description,
        :full_name
        )
    end
end
