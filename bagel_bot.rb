# encoding: utf-8

require 'cinch'
require 'cinch/plugins/identify'
require 'yaml'
require './cq'
require './pick'
require './slap'

config = YAML.load_file("./config.yml")

bot = Cinch::Bot.new do
  configure do |c|
    c.server      = "irc.mibbit.com"
    c.channels    = ["#cquest"]
    c.delay_joins = :identified

    c.nick     = "BagelBot"
    c.realname = "BagelBot"
    c.user     = "BagelBot"

    c.plugins.plugins = [
      Cinch::Plugins::Identify,
      CQ,
      Pick,
      Slap
    ]

    c.plugins.options[Cinch::Plugins::Identify] = config[:nickserv]
  end

  # Shoving it here because and maintaining it manually because I don't think
  # there's a way for Cinch to know.
  on :message, /^!commands/ do |m|
    commands = [
      "!berry",
      "!block",
      "!bread",
      "!commands",
      "!find",
      "!hero",
      "!passive",
      "!skill",
      "!slap",
      "!stats",
      "!text",
      "!weapon"
    ]
    m.reply("#{m.user.nick}: #{commands.join(", ")}")
  end
end

bot.start
