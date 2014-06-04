class Repo < ActiveRecord::Base
  include Q::Methods

  #validate :github_url_exists, :on => :create
  validate :name, uniqueness: {scope: :user_name, case_sensitive: false }

  after_create ->(repo) { Repo.queue.update_repo_info(repo.id) },
               ->(repo) { Repo.queue.populate_docs(repo.id)    }

  before_validation :downcase_name, :strip_whitespaces, :split_from_full_name, :set_full_name

  validates :name, :user_name, :presence => true
  validates :name, :uniqueness => {:scope => :user_name}

  has_many :repo_subscriptions, dependent: :destroy
  has_many :users, :through => :repo_subscriptions

  has_many :subscribers, through: :repo_subscriptions, source: :user
  has_many :doc_classes, dependent: :destroy
  has_many :doc_methods, dependent: :destroy
  alias_attribute :exclude, :excluded

  def process!
    fetcher = GithubFetcher.new(full_name)
    parser  = DocsDoctor::Parsers::Ruby::Yard.new(fetcher.clone)
    parser.process
    parser.store(self)
  end

  queue(:populate_docs) do |id|
    begin
      Repo.find(id).process!
    rescue Resque::TermException
      queue.populate_docs(id)
    end
  end

  queue(:update_repo_info) do |id|
    Repo.find(id).update_from_github
  end

  def methods_missing_docs
    doc_methods.where(doc_methods: {doc_comments_count: 0})
  end

  def methods_with_docs
    doc_methods.where("doc_comments_count > 0")
  end

  def classes_missing_docs
    doc_classes.where(doc_classes: {doc_comments_count: 0})
  end

  def strip_whitespaces
    self.name.try :strip!
    self.user_name.try :strip!
  end

  def split_from_full_name
    return true if full_name.blank?
    self.user_name, self.name = full_name.split('/')
  end

  def set_full_name
    return true if full_name.present?
    self.full_name = "#{user_name}/#{name}"
  end

  def subscriber_count
    users.count
  end

  # pulls out number of issues divided by number of subscribers
  def self.order_by_need
     joins(:repo_subscriptions).order("issues_count::float/COUNT(repo_subscriptions.repo_id) DESC").group("repos.id")
  end

  # these repos have no subscribers and have no buisness being in our database
  def self.inactive
    joins("LEFT OUTER JOIN repo_subscriptions on repos.id = repo_subscriptions.repo_id").where("repo_subscriptions.repo_id is null")
  end

  def self.not_in(*ids)
    where("repos.id not in (?)", ids)
  end

  def self.rand
    order("random()")
  end

  def self.all_languages
    self.select("language").group("language").map(&:language)
  end

  def self.repos_needing_help_for_user(user)
    if user && user.has_favorite_languages?
      self.where(language: user.favorite_languages).order_by_issue_count
    else
      self.order_by_issue_count
    end
  end

  def force_issues_count_sync!
     self.update_attributes(issues_count: self.issues.where(state: "open").count)
  end

  def to_param
    username_repo
  end

  def downcase_name
    self.name      = self.name.try :downcase
    self.user_name = self.user_name.try :downcase
  end

  #def github_url_exists
    #return true if Rails.env.test? ## TODO fixme with propper stubs, perhaps factories
    #response = GitHubBub.get(api_issues_path, page: 1, sort: 'comments', direction: 'desc')
    #if response.code != 200
      #errors.add(:expiration_date, "cannot reach api.github.com/#{api_issues_path} perhaps github is down, or you mistyped something?")
    #end
  #end

  def github_url
    File.join("https://github.com", username_repo)
  end

  def issues_url
    File.join(github_url, 'issues')
  end

  def path
    username_repo
  end

  def api_issues_path
    File.join('repos', path, '/issues')
  end

  def api_issues_url
    File.join("https://api.github.com", api_issues_path)
  end

  def username_repo
    "#{user_name}/#{name}"
  end

  def self.queue_populate_open_issues!
    find_each do |repo|
      repo.populate_issues!
    end
  end

  def self.exists_with_name?(name)
    Repo.all.collect{|r| r.username_repo}.include? name
  end


  def populate_issue(options = {})
    page  = options[:page]||1
    state = options[:state]||"open"
    response = GitHubBub.get(api_issues_path, state:     state,
                                              page:      page,
                                              sort:      'comments',
                                              direction: 'desc')
    response.json_body.each do |issue_hash|
      logger.info "Issue: number: #{issue_hash['number']}, updated_at: #{issue_hash['updated_at']}"
      Issue.find_or_create_from_hash!(issue_hash, self)
    end
    response
  end


  def populate_multi_issues!(options = {})
    options[:state] ||= "open"
    options[:page]  ||= 1
    response = populate_issue(options)
    until response.last_page?
      options[:page] += 1
      response = populate_issue(options)
    end
  end

  def update_from_github
    resp = GitHubBub.get(repo_path)

    self.language    = resp.json_body['language']
    self.description = resp.json_body['description']
    self.save
  end

  def repo_path
    File.join 'repos', path
  end
end

