# encoding: utf-8

require 'cinch'
require 'json'

require './cq/data_finder'
require './cq/message_formatter'

class CQ
  include Cinch::Plugin

  include CQ::DataFinder
  include CQ::MessageFormatter

  # Get a text whose key or value matches a query. Optionally pass a result number.
  # Can query with regex.
  #
  # Usage: !text query [num]
  # Examples:
  #   !text meow
  #   !text meow 7
  #   !text /mon_.*_name/i
  #   !text /mon_.*_name/i 3
  match(/text(?:$|(?: (.+)?))/, method: :cmd_text)
  def cmd_text(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !text query [num]")
        return
      end

      opts  = opts.strip.split
      num   = opts.last == opts.last.to_i.to_s ? opts.pop.to_i : 1
      query = opts.join(" ")

      text = find_text(query)
      num = 1 if num > text.count

      message = formatted_text_message(query, num, text)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get a list of names of a type of data. Returns first 50 results if over 50 results.
  # Can query with regex.
  #
  # Usage: !find (berry|bread|hero|skill) query
  # Examples:
  #   !find hero vesper
  #   !find skill goddess
  #   !find hero /ri$/i
  match(/find(?:$|(?: (\S+)?(?:$| (.+)?)))/, method: :cmd_find)
  def cmd_find(m, type, query)
    message_on_error(m) do
      if query.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !find (berry|bread|hero|skill) query")
        return
      end

      results = case type.downcase
                when "berry"
                  find_berries_by_name(query)
                when "bread"
                  find_breads_by_name(query)
                when "hero"
                  find_heroes_by_name(query)
                when "skill"
                  find_skills_by_name(query)
                end

      message = results ? formatted_find_message(type, query, results) : "Error - Unknown type: #{type} | Available types - berry, bread, hero, skill"
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get data about a hero. Optionally pass the hero's star level to narrow results.
  # Can query with regex.
  #
  # Usage: !hero query [stars]
  # Examples:
  #   !hero vesper
  #   !hero vesper 6
  #   !hero /a(l|r)tair/i
  #   !hero /a(l|r)tair/i 6
  match(/hero(?:$|(?: (.+)?))/, method: :cmd_hero)
  def cmd_hero(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !hero query [stars]")
        return
      end

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      hero, hero_stats = find_hero_and_stats(query, stars)

      message = formatted_hero_message(query, stars, hero, hero_stats)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get data about a hero's block skill. Optionally pass the hero's star level to narrow results.
  # Can query with regex.
  #
  # Usage: !block query [stars]
  # Examples:
  #   !block vesper
  #   !block vesper 6
  #   !block /a(l|r)tair/i
  #   !block /a(l|r)tair/i 6
  match(/block(?:$|(?: (.+)?))/, method: :cmd_block)
  def cmd_block(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !block query [stars]")
        return
      end

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      hero, hero_stats = find_hero_and_stats(query, stars)

      message = formatted_block_message(query, stars, hero, hero_stats)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get data about a hero's passive. Optionally pass the hero's star level to narrow results.
  # Can query with regex.
  #
  # Usage: !passive query [stars]
  # Examples:
  #   !passive vesper
  #   !passive vesper 6
  #   !passive /a(l|r)tair/i
  #   !passive /a(l|r)tair/i 6
  match(/passive(?:$|(?: (.+)?))/, method: :cmd_passive)
  def cmd_passive(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !passive query [stars]")
        return
      end

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      hero, hero_stats = find_hero_and_stats(query, stars)

      message = formatted_passive_message(query, stars, hero, hero_stats)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get the stats of a hero at specified star, level, training, and berry.
  # Defaults to maximum level, training, and berry for the found hero.
  # Can query with regex.
  #
  # Usage: !stats query [stars [level bread berry]]
  # Examples:
  #   !stats may
  #   !stats may 6
  #   !stats may 6 52 3 false
  match(/stats(?:$|(?: (.+)?))/, method: :cmd_stats)
  def cmd_stats(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !stats query [stars [level bread berry]]")
        return
      end

      opts  = opts.strip.split
      berry = nil
      bread = nil
      level = nil
      stars = nil

      if opts.length >= 5 && ["true", "false"].include?(opts.last)
        berry = opts.pop == "true"
        bread = opts.pop.to_i
        level = opts.pop.to_i
        stars = opts.pop.to_i
      elsif [1,2,3,4,5,6].include?(opts.last.to_i)
        stars = opts.pop.to_i
      end

      query = opts.join(" ")

      hero, hero_stats = find_hero_and_stats(query, stars)
      berry_stats      = find_berry_stats_by_id(hero_stats["addstat_max_id"]) if hero_stats

      message = formatted_stats_message(query, stars, level, bread, berry, hero, hero_stats, berry_stats)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get data about an sp skill. Optionally pass a level for the skill.
  # Defaults to the maximum level for the skill.
  # Can query with regex.
  #
  # Usage: !skill query [level]
  # Examples:
  #   !skill energy
  #   !skill energy 2
  match(/skill(?:$|(?: (.+)?))/, method: :cmd_skill)
  def cmd_skill(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !skill query [level]")
        return
      end

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

  # Get data about a type of bread. Optionally pass a star level for the bread.
  # Can query with regex.
  #
  # Usage: !bread query [stars]
  # Examples:
  #   !bread donut
  #   !bread
  #   !bread /ry.*/i
  match(/bread(?:$|(?: (.+)?))/, method: :cmd_bread)
  def cmd_bread(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !bread query [stars]")
        return
      end

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      breads = find_breads_by_name(query.strip)
      bread = stars ? breads.find { |b| b["grade"] == stars } : breads.first

      message = formatted_bread_message(query, stars, bread)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get data about a type of berry. Optionally pass a star level for the berry.
  # Can query with regex.
  #
  # Usage: !berry query [stars]
  # Examples:
  #   !berry attack
  #   !berry attack 2
  #   !berry /(superior|legend)/i
  match(/berry(?:$|(?: (.+)?))/, method: :cmd_berry)
  def cmd_berry(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !berry query [stars]")
        return
      end

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      berries = find_berries_by_name(query.strip)
      berry = stars ? berries.find { |b| b["grade"] == stars } : berries.first

      message = formatted_berry_message(query, stars, berry)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get data about a weapon. Optionally pass a star level for the weapon.
  # Can query with regex.
  #
  # Usage: !weapon query [stars]
  # Examples:
  #   !weapon excalibur
  #   !weapon /sword$/i 6
  match(/weapon(?:$|(?: (.+)?))/, method: :cmd_weapon)
  def cmd_weapon(m, opts)
    message_on_error(m) do
      if opts.nil?
        m.reply("#{m.user.nick}: Error - Missing parameters! | Usage - !weapon query [stars]")
        return
      end

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")

      weapons = find_weapons_by_name(query.strip)
      weapon = stars ? weapons.find { |w| w["grade"] == stars } : weapons.first
      bound_to = find_heroes_by_ids(Array(weapon["reqhero"]))

      message = formatted_weapon_message(query, stars, weapon, bound_to)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # All commands should be run through this so that it reports back to the user and
  # pings me if an error occurs
  def message_on_error(m, &block)
    begin
      block.call
    rescue => e
      m.reply("#{m.user.nick}: Error - Blargel is a scrub at programming!")
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
