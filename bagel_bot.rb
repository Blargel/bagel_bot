# encoding: utf-8

require 'cinch'
require 'cinch/plugins/identify'
require 'yaml'

lib = File.expand_path("../plugins", __FILE__)
$LOAD_PATH.unshift(lib)

require 'calc'
require 'cq'
require 'pick'
require 'slap'

config = YAML.load_file("./config.yml") rescue nil

config ||= {
  :nickserv => {
    :type => :nickserv,
    :username => ENV["NICKSERV_USERNAME"],
    :password => ENV["NICKSERV_PASSWORD"]
  }
}

bot = Cinch::Bot.new do
  configure do |c|
    c.server      = "irc.mibbit.com"
    c.channels    = ["#cquest"]

    c.nick     = "BagelBot"
    c.realname = "BagelBot"
    c.user     = "BagelBot"

    c.max_messages = 4

    c.plugins.prefix = /^\$/
    c.plugins.plugins = [
      Cinch::Plugins::Identify,
      Calc,
      CQ,
      Pick,
      Slap
    ]

    c.plugins.options[Cinch::Plugins::Identify] = config[:nickserv]
  end

  # Shoving it here because and maintaining it manually because I don't think
  # there's a way for Cinch to know.
  on :message, /^\$(commands|help)/ do |m|
    commands = [
      "$berry",
      "$berrystats",
      "$block",
      "$bread",
      "$calc",
      "$champ",
      "$champion",
      "$championskill",
      "$champskill",
      "$commands",
      "$faction",
      "$find",
      "$help",
      "$hero",
      "$highscore",
      "$monstats",
      "$monsterstats",
      "$passive",
      "$pick",
      "$sbw",
      "$skill",
      "$slap",
      "$stage",
      "$stats",
      "$text",
      "$weapon"
    ]
    m.reply("#{m.user.nick}: #{commands.join(", ")}")
  end
end

bot.start
