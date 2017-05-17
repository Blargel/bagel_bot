# encoding: utf-8

require 'yaml'
require 'json'
require 'cinch'
require 'sequel'

class CQ
  DB_CONFIG = ENV["DATABASE_URL"] || YAML.load_file(File.expand_path("../cq/db/database.yml", __FILE__))
  DB = Sequel.connect(DB_CONFIG)
end

require 'cq/db/models/berry'
require 'cq/db/models/bread'
require 'cq/db/models/hero'
require 'cq/db/models/monster'
require 'cq/db/models/skill'
require 'cq/db/models/skin'
require 'cq/db/models/stage'
require 'cq/db/models/stages_monster'
require 'cq/db/models/text'
require 'cq/db/models/weapon'

require 'cq/message_formatter'

class CQ
  include Cinch::Plugin
  include CQ::MessageFormatter

  # Get a text whose key or value matches a query. Optionally pass a result number.
  # Can query with regex.
  #
  # Usage: $text query [num]
  # Examples:
  #   $text meow
  #   $text meow 7
  #   $text /mon_.*_name/i
  #   $text /mon_.*_name/i 3
  match(/text(?:$|(?: (.+)?))/, method: :cmd_text)
  def cmd_text(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $text query [num]") unless opts

      opts  = opts.strip.split
      num   = opts.last == opts.last.to_i.to_s ? opts.pop.to_i : 1
      query = opts.join(" ")
      regex = string_to_regex(query)

      texts = CQ::Text.filter_matches(regex || query).all

      raise CQ::Error.new("No matches found for #{query}!") if texts.empty?

      m.reply("#{m.user.nick}: #{formatted_text_message(num, texts)}")
    end
  end

  # Get a list of names of a type of data. Returns first 50 results if over 50 results.
  # Can query with regex.
  #
  # Usage: $find (berry|bread|hero|monster|skill|weapon) query
  # Examples:
  #   $find hero vesper
  #   $find skill goddess
  #   $find hero /ri$/i
  match(/find(?:$|(?: (\S+)?(?:$| (.+)?)))/, method: :cmd_find)
  def cmd_find(m, type, query)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $find type query") unless query
      query.strip!
      regex = string_to_regex(query)

      results = case type.downcase
                when "berry"
                  CQ::Berry.filter_name(regex || query).order_more(:stars).all
                when "bread"
                  CQ::Bread.filter_name(regex || query).order_more(:stars).all
                when "hero"
                  CQ::Hero.filter_name(regex || query).order_more(:stars).all
                when "monster"
                  CQ::Monster.filter_name(regex || query).all
                when "skill"
                  CQ::Skill.filter_name(regex || query).all
                when "skin"
                  CQ::Skin.filter_name(regex || query).all
                when "weapon"
                  CQ::Weapon.filter_name_or_bound_to(regex || query).order_more(:stars).all
                else
                  raise CQ::Error.new("Unknown type: #{type} | Available types - berry, bread, hero, monster, skill, skin, weapon")
                end

      raise CQ::Error.new("No #{type} results found for \"#{query}\"") if results.empty?

      m.reply("#{m.user.nick}: #{formatted_find_message(results)}")
    end
  end

  # Get data about a hero. Optionally pass the hero's star level to narrow results.
  # Can query with regex.
  #
  # Usage: $hero query [stars]
  # Examples:
  #   $hero vesper
  #   $hero vesper 6
  #   $hero /a(l|r)tair/i
  #   $hero /a(l|r)tair/i 6
  match(/hero(?:$|(?: (.+)?))/, method: :cmd_hero)
  def cmd_hero(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $hero query [stars]") unless opts

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")
      regex = string_to_regex(query)

      heroes = CQ::Hero.filter_stars(stars).filter_name(regex || query)
      hero = heroes.first

      raise CQ::Error.new("No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!") unless hero

      m.reply("#{m.user.nick}: #{formatted_hero_message(hero)}")
    end
  end

  # Get data about a hero's block skill. Optionally pass the hero's star level to narrow results.
  # Can query with regex.
  #
  # Usage: $block query [stars]
  # Examples:
  #   $block vesper
  #   $block vesper 6
  #   $block /a(l|r)tair/i
  #   $block /a(l|r)tair/i 6
  match(/block(?:$|(?: (.+)?))/, method: :cmd_block)
  def cmd_block(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $block query [stars]") unless opts

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")
      regex = string_to_regex(query)

      heroes = CQ::Hero.filter_stars(stars).filter_name(regex || query)
      hero = heroes.first

      raise CQ::Error.new("No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!") unless hero

      m.reply("#{m.user.nick}: #{formatted_block_message(hero)}")
    end
  end

  # Get data about a hero's passive. Optionally pass the hero's star level to narrow results.
  # Can query with regex.
  #
  # Usage: $passive query [stars]
  # Examples:
  #   $passive vesper
  #   $passive vesper 6
  #   $passive /a(l|r)tair/i
  #   $passive /a(l|r)tair/i 6
  match(/passive(?:$|(?: (.+)?))/, method: :cmd_passive)
  def cmd_passive(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $passive query [stars]") unless opts

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")
      regex = string_to_regex(query)

      heroes = CQ::Hero.filter_stars(stars).filter_name(regex || query)
      hero = heroes.first

      raise CQ::Error.new("No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!") unless hero

      m.reply("#{m.user.nick}: #{formatted_passive_message(hero)}")
    end
  end

  # Get the stats of a hero at specified star, level, training, and berry.
  # Defaults to maximum level, training, and berry for the found hero.
  # Can query with regex.
  #
  # Usage: $stats query [stars [level bread berry]]
  # Examples:
  #   $stats may
  #   $stats may 6
  #   $stats may 6 52 3 false
  match(/stats(?:$|(?: (.+)?))/, method: :cmd_stats)
  def cmd_stats(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $stats query [stars [level bread berry]]") unless opts

      opts = opts.strip.split
      with_berry = nil
      bread = nil
      level = nil
      stars = nil

      if opts.length >= 5 && ["true", "false"].include?(opts.last)
        with_berry = opts.pop == "true"
        bread = opts.pop.to_i
        level = opts.pop.to_i
        stars = opts.pop.to_i
      elsif [1,2,3,4,5,6].include?(opts.last.to_i)
        stars = opts.pop.to_i
      end

      raise CQ::Error.new("Invalid star level: #{stars}.") if stars && ![1,2,3,4,5,6].include?(stars)
      raise CQ::Error.new("Invalid level for #{stars}☆ hero: #{level}") if level && (level > stars*10 || level < 1)
      raise CQ::Error.new("Invalid training for #{stars}☆ hero: #{bread}") if bread && (bread > stars-1 || bread < 0)

      query = opts.join(" ")
      regex = string_to_regex(query)

      heroes = CQ::Hero.filter_stars(stars).filter_name(regex || query)
      hero = heroes.first

      raise CQ::Error.new("No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!") unless hero

      level ||= hero.stars*10
      bread ||= hero.stars-1
      with_berry = true if with_berry.nil?

      m.reply("#{m.user.nick}: #{formatted_stats_message(hero, level, bread, with_berry)}")
    end
  end

  # Get data about an sp skill. Optionally pass a level for the skill.
  # Defaults to the maximum level for the skill.
  # Can query with regex.
  #
  # Usage: $skill query [level]
  # Examples:
  #   $skill energy
  #   $skill energy 2
  match(/skill(?:$|(?: (.+)?))/, method: :cmd_skill)
  def cmd_skill(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $skill query [level]") unless opts

      opts  = opts.strip.split
      level = opts.last == opts.last.to_i.to_s ? opts.pop.to_i : nil
      query = opts.join(" ")
      regex = string_to_regex(query)

      skills = CQ::Skill.filter_level(level).filter_name(regex || query).all
      skill = skills.max { |a, b| a.level <=> b.level }

      raise CQ::Error.new("No skills match name \"#{query}\"#{" and level #{level}!" if level}") if skill.nil?

      message = formatted_skill_message(skill)
      m.reply("#{m.user.nick}: #{message}")
    end
  end

  # Get data about a type of bread. Optionally pass a star level for the bread.
  # Can query with regex.
  #
  # Usage: $bread query [stars]
  # Examples:
  #   $bread donut
  #   $bread
  #   $bread /ry.*/i
  match(/bread(?:$|(?: (.+)?))/, method: :cmd_bread)
  def cmd_bread(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $bread query [stars]") unless opts

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")
      regex = string_to_regex(query)

      bread = CQ::Bread.filter_stars(stars).filter_name(regex || query).first

      raise CQ::Error.new("No #{ stars.to_s + "☆ " if stars}bread names match \"#{query}\"!") unless bread

      m.reply("#{m.user.nick}: #{formatted_bread_message(bread)}")
    end
  end

  # Get data about a type of berry. Optionally pass a star level for the berry.
  # Can query with regex.
  #
  # Usage: $berry query [stars]
  # Examples:
  #   $berry attack
  #   $berry attack 2
  #   $berry /(superior|legend)/i
  match(/berry(?:$|(?: (.+)?))/, method: :cmd_berry)
  def cmd_berry(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $berry query [stars]") unless opts

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")
      regex = string_to_regex(query)

      berry = CQ::Berry.filter_stars(stars).filter_name(regex || query).first

      raise CQ::Error.new("No #{ stars.to_s + "☆ " if stars}berry names match \"#{query}\"!") unless berry

      m.reply("#{m.user.nick}: #{formatted_berry_message(berry)}")
    end
  end

  # Get data on the maximum berryable stats on a hero. Returns 6* heroes only.
  # Can query with regex.
  #
  # Usage: $berrystats query
  # Examples:
  #   $berrystats rochefort
  #   $berrystats /a(l|r)tair
  match(/berrystats(?:$|(?: (.+)?))/, method: :cmd_berrystats)
  def cmd_berrystats(m, query)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $berrystats query") unless query

      query.strip!
      regex = string_to_regex(query)

      heroes = CQ::Hero.filter_stars(6).filter_name(regex || query)
      hero = heroes.first

      raise CQ::Error.new("No 6☆ hero's name matches \"#{query}\"!") unless hero

      m.reply("#{m.user.nick}: #{formatted_berrystats_message(hero)}")
    end
  end

  # Get data about a weapon. Optionally pass a star level for the weapon.
  # Can query with regex.
  #
  # Usage: $weapon query [stars]
  # Examples:
  #   $weapon excalibur
  #   $weapon /sword$/i 6
  match(/weapon(?:$|(?: (.+)?))/, method: :cmd_weapon)
  def cmd_weapon(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $weapon query [stars]") unless opts

      opts  = opts.strip.split
      stars = [1,2,3,4,5,6].include?(opts.last.to_i) ? opts.pop.to_i : nil
      query = opts.join(" ")
      regex = string_to_regex(query)

      weapon = CQ::Weapon.filter_stars(stars).filter_name(regex || query).first

      raise CQ::Error.new("No #{ stars.to_s + "☆ " if stars}weapon names match \"#{query}\"!") unless weapon

      m.reply("#{m.user.nick}: #{formatted_weapon_message(weapon)}")
    end
  end

  # Find the heroes with the highest stats. Optionally restrict it to one stat and/or class.
  # List of valid stats:
  #   ha, hp, cc, arm, res, cd, acc, eva,
  #   berryha, berryhp, berrycc, berryarm,
  #   berryres, berrycd, berryacc, berryeva
  # List of valid classes:
  #   warrior, paladin, archer, hunter, wizard, priest
  #
  # Usage: $highscore [stat [class]]
  # Examples:
  #   $highscore
  #   $highscore ha
  #   $highscore ha priest
  match(/highscore(?:$|(?: (\S+)?(?:$| (.+)?)))/, method: :cmd_highscore)
  def cmd_highscore(m, stat, hero_class)
    message_on_error(m) do
      regular_stats = ["ha", "hp", "arm", "res", "cc", "cd", "acc", "eva"]
      berry_stats   = ["berryha", "berryhp", "berryarm", "berryres", "berrycc", "berrycd", "berryacc", "berryeva"]

      valid_stats   = regular_stats + berry_stats
      valid_classes = ["warrior", "paladin", "archer", "hunter", "wizard", "priest"]

      stat.downcase! if stat
      hero_class.downcase! if hero_class

      raise CQ::Error.new("Invalid stat: #{stat}. Valid stats: #{valid_stats.join(", ")}") if stat && !valid_stats.include?(stat)
      raise CQ::Error.new("Invalid class: #{hero_class}. Valid classes: #{valid_classes.join(", ")}") if hero_class && !valid_classes.include?(hero_class)

      results = nil
      if stat
        stat.gsub!("berry", "berry_") if berry_stats.include?(stat)

        dataset = DB[:max_hero_stats].select(:name, Sequel.identifier(stat).as("value")).order(stat.to_sym).reverse
        dataset = dataset.where(:hero_class => hero_class.capitalize) if hero_class
        results = dataset.first(10)
      else
        results = {}
        valid_stats.each do |s|
          s = s.gsub("berry", "berry_") if berry_stats.include?(s)
          results[s] = DB[:max_hero_stats].select(:name, Sequel.identifier(s).as("value")).order(s.to_sym).reverse.first
        end
      end

      m.reply("#{m.user.nick}: #{formatted_highscore_message(results, stat)}")
    end
  end

  # Get data about a stage.
  #
  # Usage: $stage code
  # Examples:
  #   $stage 1-1n
  #   $stage 6-30h
  #   $stage 7-3-2n
  match(/stage(?:$|(?: (.+)?))/, method: :cmd_stage)
  def cmd_stage(m, code)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $stage code") unless code
      raise CQ::Error.new("Invalid stage code format. Use a format like 6-30h or 7-1-8n.") unless code.strip =~ /\d\-\d\d?(?:\-\d\d?)?n|h/i

      stage = CQ::Stage.find_by_code(code.strip)

      raise CQ::Error.new("Invalid stage: #{code}") unless stage

      m.reply("#{m.user.nick}: #{formatted_stage_message(stage)}")
    end
  end

  # Get the stats of a monster at specified level.
  # Can query with regex.
  #
  # Usage: $monstats query level
  # Examples:
  #   $monstats el thalnos 135
  #   $monstats /b.*ogre/i 128
  match(/mon(?:ster)?stats(?:$|(?: (.+)?))/, method: :cmd_monstats)
  def cmd_monstats(m, opts)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $monsterstats query level") unless opts && opts.strip.include?(" ")

      opts  = opts.strip.split
      level = opts.pop
      query = opts.join(" ")
      regex = string_to_regex(query)

      raise CQ::Error.new("Invalid level: #{level}") if level.to_i < 1 || level.to_i.to_s != level

      monster = CQ::Monster.filter_name(regex || query).first

      raise CQ::Error.new("No monsters's name matches \"#{query}\"!") unless monster

      m.reply("#{m.user.nick}: #{formatted_monsterstats_message(monster, level.to_i)}")
    end
  end

  # Get data about a skin.
  # Can query with regex.
  #
  # Usage: $skin query
  # Examples:
  #   $skin d'art
  match(/skin(?:$|(?: (.+)?))/, method: :cmd_skin)
  def cmd_skin(m, query)
    message_on_error(m) do
      raise CQ::Error.new("Missing parameters! | Usage - $skin query") unless query

      query = query.strip
      regex = string_to_regex(query)

      skin = CQ::Skin.filter_name(regex || query).first

      raise CQ::Error.new("No skin's name matches \"#{query}\"!") unless skin

      m.reply("#{m.user.nick}: #{formatted_skin_message(skin)}")
    end
  end


  class Error < StandardError
  end
  # All commands should be run through this so that it reports back to the user and
  # pings me if an error occurs
  def message_on_error(m, &block)
    begin
      block.call
    rescue => e
      if e.kind_of?(CQ::Error)
        m.reply("#{m.user.nick}: Error - #{e.message}")
      else
        m.reply("#{m.user.nick}: Error - Blargel is a scrub at programming!")
        raise e
      end
    end
  end

  # Converts a string to a regex. Returns nil if it can't be converted.
  # Only works on regular regex (i.e. /foo/) or case insensitive regex (i.e. /bar/i)
  def string_to_regex(str)
    if str.length > 1 && str[0] == "/" && (str[-1] == "/" || str[-2..-1] == "/i")
      insensitive = str[-1] == "i"
      insensitive ? Regexp.new(str[1..-3], true) : Regexp.new(str[1..-2])
    end
  end

end
