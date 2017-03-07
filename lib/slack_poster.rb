require 'httparty'
require 'json'

class SlackPoster

  attr_accessor :webhook_url, :poster, :mood, :mood_hash, :channel, :season_name, :halloween_season, :festive_season

  def initialize(webhook_url, team_channel, mood)
    @webhook_url = webhook_url
    @team_channel = team_channel
    @mood = mood
    @today = Date.today
    @postable_day = !today.saturday? && !today.sunday?
    mood_hash
  end

  def send_request(message)
  	puts message
    HTTParty.post("https://hooks.slack.com/services/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", body: {username: "#{@mood_hash[:username]}", icon_emoji: "#{@mood_hash[:icon_emoji]}", text: "#{message}"}.to_json)
  end

  private

  attr_reader :postable_day, :today

  def mood_hash
    @mood_hash = {}
    check_season
    check_if_quotes
    assign_poster_settings
  end

  def assign_poster_settings
    if @mood == "informative"
      @mood_hash[:icon_emoji]= ":#{@season_symbol}informative_fabricio:"
      @mood_hash[:username]= "#{@season_name}Informative Fabricio"
    elsif @mood == "approval"
      @mood_hash[:icon_emoji]= ":#{@season_symbol}informative_fabricio:"
      @mood_hash[:username]= "#{@season_name}Fabricio of Approval"
    elsif @mood == "angry"
      @mood_hash[:icon_emoji]= ":#{@season_symbol}angrier_fabricio:"
      @mood_hash[:username]= "#{@season_name}Angry Fabricio"
    elsif @mood == "tea"
      @mood_hash[:icon_emoji]= ":manatea:"
      @mood_hash[:username]= "Tea Seal"
    elsif @mood == "charter"
      @mood_hash[:icon_emoji]= ":happyseal:"
      @mood_hash[:username]= "Team Charter Seal"
    else
      fail "Bad mood: #{mood}."
    end
  end

  def check_season
    if halloween_season?
      @season_name = "Halloween "
    elsif festive_season?
      @season_name = "Festive Season "
    else
      @season_name = ""
    end
    @season_symbol = "brunobots_" + snake_case(@season_name)
  end

  def halloween_season?
    this_year = today.year
    today <= Date.new(this_year, 10, 31) && today >= Date.new(this_year,10,23)
  end

  def festive_season?
    this_year = today.year
    return true if today <= Date.new(this_year, 12, 31) && today >= Date.new(this_year,12,1)
    today == Date.new(this_year, 01, 01)
  end

  def snake_case(string)
    string.downcase.gsub(" ", "_")
  end

  def check_if_quotes
    if @team_channel == "#tea"
      @mood = "tea"
      @postable_day = today.friday?
    elsif @mood == nil
      @mood = "charter"
      @postable_day = today.tuesday? || today.thursday?
    end
  end
end
