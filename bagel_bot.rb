# encoding: utf-8

require 'cinch'
require 'cinch/plugins/identify'
require './cq'

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

    c.plugins.options[Cinch::Plugins::Identify] = {
      :username => "BagelBot",
      :password => "asdfjklsemicolon",
      :type     => :nickserv,
    }
  end
end

bot.start
