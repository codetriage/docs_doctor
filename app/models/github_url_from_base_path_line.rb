class GithubUrlFromBasePathLine

  # GithubUrlFromBasePathLine.new(repo.github_url)
  def initialize(base, path, line)
    @base = Pathname.new(base)
    @line = line
    @path = path
  end

  # https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/collector.rb#L10
  def to_github
    @base.join("blob/master", @path, "#L#{@line}")
  end
end
