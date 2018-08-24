# coding: utf-8
require 'google_calendar'
require 'json'
require 'yaml'

module CalendarAssistant
  CLIENT_ID_FILE = "client_id.json"
  CALENDAR_TOKENS_FILE = "calendar_tokens.yml"
  
  EMOJI_WORLDMAP  = "🗺" # U+1F5FA WORLD MAP
  EMOJI_PUSHPIN   = "📍" # U+1F4CD ROUND PUSHPIN
  EMOJI_FLAG      = "🚩" # U+1F6A9 TRIANGULAR FLAG ON POST
  EMOJI_PLANE     = "🛪" # U+1F6EA NORTHEAST-POINTING AIRPLANE

  def self.token_for calendar_id
    calendar_tokens = File.exists?(CALENDAR_TOKENS_FILE) ?
                        YAML.load(File.read(CALENDAR_TOKENS_FILE)) :
                        Hash.new
    calendar_tokens[calendar_id]
  end

  def self.save_token_for calendar_id, refresh_token
    calendar_tokens = File.exists?(CALENDAR_TOKENS_FILE) ?
                        YAML.load(File.read(CALENDAR_TOKENS_FILE)) :
                        Hash.new
    calendar_tokens[calendar_id] = refresh_token
    File.open(CALENDAR_TOKENS_FILE, "w") { |f| f.write calendar_tokens.to_yaml }
  end

  def self.params_for calendar_id
    client_id = JSON.parse(File.read(CLIENT_ID_FILE))
    {
      :client_id     => client_id["installed"]["client_id"],
      :client_secret => client_id["installed"]["client_secret"],
      :calendar      => CALENDAR_ID,
      :redirect_url  => "urn:ietf:wg:oauth:2.0:oob",
      :refresh_token => CalendarAssistant.token_for(CALENDAR_ID),
    }
  end

  def self.calendar_for calendar_id
    Google::Calendar.new params_for(calendar_id)
  end

  def self.calendar_list_for calendar_id
    Google::CalendarList.new params_for(calendar_id)
  end
end
