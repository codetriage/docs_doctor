class GithubUrlFromBasePathLine

  def initialize(base, path, line)
    @base = base
    @line = line
    @path = path
  end

  # https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/collector.rb#L10
  def to_github
    File.join(@base, "blob/master", @path, "#L#{@line}")
  end
end
