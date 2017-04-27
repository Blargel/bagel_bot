# encoding: utf-8

require 'cinch'
require 'cinch/plugins/identify'
require 'yaml'
require './cq'

config = YAML.load_file("./config.yml")

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = "irc.mibbit.com"
    c.channels = ["#cquest"]

    c.nick     = "BagelBot"
    c.realname = "BagelBot"
    c.user     = "BagelBot"

    c.plugins.plugins = [
      CQ,
      Cinch::Plugins::Identify
    ]

    c.plugins.options[Cinch::Plugins::Identify] = config[:nickserv]
  end
end

bot.start
