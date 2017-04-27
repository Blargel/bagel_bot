# encoding: utf-8

require 'cinch'
require 'json'

require './cq/data_finder'
require './cq/message_formatter'

class CQ
  include Cinch::Plugin

  include CQ::DataFinder
  include CQ::MessageFormatter

  match(/text (.+)/,         method: :cmd_text)
  match(/find (\S+) ?(.+)?/, method: :cmd_find)
  match(/hero (.+)/,         method: :cmd_hero)
  match(/block (.+)/,        method: :cmd_block)
  match(/passive (.+)/,      method: :cmd_passive)
  match(/skill (.+)/,        method: :cmd_skill)

  def cmd_text(m, opts)
    message_on_error(m) do
      opts  = opts.strip.split
      num   = opts.last == opts.last.to_i.to_s ? opts.pop.to_i : 1
      query = opts.join(" ")

      text = find_text(query)
      num = 1 if num > text.count

      message = formatted_text_message(query, num, text)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  def cmd_find(m, type, query)
    message_on_error(m) do
      results = if type.downcase == "hero"
                  find_heroes_by_name(query)
                elsif type.downcase == "skill"
                  find_skills_by_name(query)
                end

      message = results ? formatted_find_message(type, query, results) : "Unknown type: #{type}. Available types: hero, skill"
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  def cmd_hero(m, opts)
    message_on_error(m) do
      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      hero, hero_stats = find_hero_and_stats(query, stars)

      message = formatted_hero_message(query, stars, hero, hero_stats)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  def cmd_block(m, opts)
    message_on_error(m) do
      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      hero, hero_stats = find_hero_and_stats(query, stars)

      message = formatted_block_message(query, stars, hero, hero_stats)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  def cmd_passive(m, opts)
    message_on_error(m) do
      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      hero, hero_stats = find_hero_and_stats(query, stars)

      message = formatted_passive_message(query, stars, hero, hero_stats)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  def cmd_skill(m, opts)
    message_on_error(m) do
      opts  = opts.strip.split
      level = opts.last == opts.last.to_i.to_s ? opts.pop.to_i : nil
      query = opts.join(" ")

      skills = find_skills_by_name(query)
      skill = if level.nil?
                skills.max { |s| s["level"] }
              else
                skills.find { |s| s["level"] == level }
              end

      message = formatted_skill_message(query, level, skill)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # All commands should be run through this so that it reports back to the user and
  # pings me if an error occurs
  def message_on_error(m, &block)
    begin
      block.call
    rescue => e
      m.reply("#{m.user.nick}: Error! Blargel is a scrub at programming!")
      raise e
    end
  end

  # Restructure the localization text JSON into something sane and save it into memory. The
  # original format is an array of single key hashes. This converts it into one big hash.
  def self.load_text
    text_files = [
      "data/get_textlocale_en_us_0.txt",
      "data/get_textlocale_en_us_1.txt",
      "data/get_textlocale_en_us_2.txt",
      "data/get_textlocale_en_us_3.txt",
      "data/get_textlocale_en_us_4.txt",
    ]
    text_files.inject({}) do |main_hash, file|
      json = JSON.parse(File.read(file))
      tmp_hash = json["textlocale"].inject({}) do |file_hash, text_hash|
        file_hash.merge(text_hash)
      end
      main_hash.merge(tmp_hash)
    end
  end
  TEXT = load_text
end
