# encoding: utf-8

require 'cinch'

class Pick
  include Cinch::Plugin

  match(/pick(?:$|(?: (.+)?))/)
  def execute(m, opts)
    m.reply("#{m.user.nick}: Give me some options to pick between separated with the word \"or\".") if opts.nil?
    choices = opts.split(" or ")

    m.reply("#{m.user.nick}: I pick... #{choices.sample}!")
  end
end
