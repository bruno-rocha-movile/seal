class MessageBuilder

  attr_accessor :pull_requests, :report, :mood, :poster_mood, :ping

  def initialize(content, ping, mode=nil)
    @content = content
    @mode = mode
    if ping != nil
      @ping = ping
    else
      @ping = "channel"
    end
  end

  def build
    if @mode == "quotes"
      bark_about_quotes
    else
      github_seal
    end
  end

  def github_seal
    if !old_pull_requests.empty?
      @poster_mood = "angry"
      bark_about_old_pull_requests
    elsif @content.empty?
      @poster_mood = "approval"
      no_pull_requests
    else
      @poster_mood = "informative"
      list_pull_requests
    end
  end

  def rotten?(pull_request)
    today = Date.today
    weekdays_age = (today - pull_request['updated']).to_i
    weekdays_age > 1
  end

  private

  def old_pull_requests
    @old_pull_requests ||= @content.select { |_title, pr| rotten?(pr) }
  end

  def bark_about_old_pull_requests
    angry_bark = old_pull_requests.keys.each_with_index.map { |title, n| present(title, n + 1) }
    recent_pull_requests = @content.reject { |_title, pr| rotten?(pr) }
    list_recent_pull_requests = recent_pull_requests.keys.each_with_index.map { |title, n| present(title, n + 1) }
    informative_bark = "Recent pull requests awaiting review:\n\n#{list_recent_pull_requests.join} " if !recent_pull_requests.empty?
    "<!#{@ping}> #{these(old_pull_requests.length)} #{pr_plural(old_pull_requests.length)} not been updated in over 2 days.\n\n#{angry_bark.join}\n\n#{informative_bark}"
  end

  def list_pull_requests
    message = @content.keys.each_with_index.map { |title, n| present(title, n + 1) }
    "<!#{@ping}> Today's pull requests:\n\n#{message.join}"
  end

  def no_pull_requests
    "No pull requests opened. Nice!"
  end

  def bark_about_quotes
    @content.sample
  end

  def comments(pull_request)
    return " comment" if @content[pull_request]["comments_count"] == "1"
    " comments"
  end

  def these(items)
    if items == 1
      'This'
    else
      'These'
    end
  end

  def pr_plural(prs)
    if prs == 1
      'pull request has'
    else
      'pull requests have'
    end
  end

  def present(pull_request, index)
    pr = @content[pull_request]
    days = age_in_days(pr)
    thumbs_up = ''
    thumbs_up = " | #{pr["thumbs_up"].to_i} :+1:" if pr["thumbs_up"].to_i > 0
    <<-EOF.gsub(/^\s+/, '')
    #{index}\) *#{pr["repo"]}* | #{pr["author"]} | updated #{days_plural(days)}#{thumbs_up}
    #{labels(pr)} <#{pr["link"]}|#{pr["title"]}> - #{pr["comments_count"]}#{comments(pull_request)}
    EOF
  end

  def age_in_days(pull_request)
    (Date.today - pull_request['updated']).to_i
  end

  def days_plural(days)
    case days
    when 0
      'today'
    when 1
      "yesterday"
    else
      "#{days} days ago"
    end
  end

  def labels(pull_request)
    pull_request['labels']
      .map { |label| "[#{label['name']}]" }
      .join(' ')
  end
end
