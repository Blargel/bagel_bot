# encoding: utf-8

require 'json'

class CQ
  module DataFinder
    # Finds text whose id or content matches a given query.
    # Checks if the query can be converted to a regex and sends to the appropriate method.
    # Returns an array of matching text.
    def find_text(text)
      regex = string_to_regex(text)
      regex ? find_text_by_regex(regex) : find_text_by_substring(text)
    end

    # Finds text whose id or content contains a given substring.
    # Returns an array of matching text.
    def find_text_by_substring(text)
      matching_texts = []

      CQ::TEXT.each do |k, v|
        if k.to_s.downcase.include?(text.downcase) || v.to_s.downcase.include?(text.downcase)
          matching_texts << [k, v]
        end
      end

      matching_texts
    end

    # Finds text whose id or content matches a given regex.
    # Returns an array of matching text.
    def find_text_by_regex(regex)
      matching_texts = []

      CQ::TEXT.each do |k, v|
        if k =~ regex || v =~ regex
          matching_texts << [k, v]
        end
      end

      matching_texts
    end

    # Finds a hero whose name matches a given query and star level.
    # Returns a hero hash and a matching stat hash.
    def find_hero_and_stats(query, stars)
      heroes = find_heroes_by_name(query)

      return if heroes.empty?

      if stars
        hero_stats = nil
        hero = heroes.find do |h|
                 hero_stats = find_hero_stats_by_id(h["default_stat_id"])
                 hero_stats["grade"] == stars
               end
        return if hero.nil?
        [hero, hero_stats]
      else
        hero_stats = find_hero_stats_by_id(heroes.first["default_stat_id"])
        [heroes.first, hero_stats]
      end
    end

    # Finds heroes whose names match a given query.
    # Checks if the query can be converted to a regex and sends to the appropriate method.
    # Returns an array of matching hero hashes.
    def find_heroes_by_name(query)
      regex = string_to_regex(query)
      regex ? find_heroes_by_name_regex(regex) : find_heroes_by_name_substring(query)
    end

    # Finds heroes whose names match a given substring.
    # Returns an array of matching hero hashes.
    # The order of the array is determined by how the substring was matched:
    #   1. Exact string match
    #   2. Exact word match
    #   3. Start of string match
    #   4. Start of word match
    #   5. All other matches
    def find_heroes_by_name_substring(substr)
      hero_data = get_data("character_visual")
      substr = substr.downcase

      exact_matches        = []
      exact_word_matches   = []
      string_start_matches = []
      word_start_matches   = []
      other_matches        = []
      hero_data.each do |hero|
        next unless hero["type"] == "HERO"

        hero_name = CQ::TEXT[hero["name"]].to_s.downcase

        if hero_name == substr
          exact_matches << hero
        elsif hero_name =~ /(^|\s)#{Regexp.quote(substr)}($|\s)/
          exact_word_matches << hero
        elsif hero_name =~ /^#{Regexp.quote(substr)}/
          string_start_matches << hero
        elsif hero_name =~ /\s#{Regexp.quote(substr)}/
          word_start_matches << hero
        elsif hero_name.include?(substr)
          other_matches << hero
        end
      end

      exact_matches + exact_word_matches + string_start_matches + word_start_matches + other_matches
    end

    # Finds heroes whose names match a given regex.
    # Returns an array of matching hero hashes.
    def find_heroes_by_name_regex(regex)
      hero_data = get_data("character_visual")
      hero_data.keep_if do |hero|
        hero["type"] == "HERO" && CQ::TEXT[hero["name"]].to_s =~ regex
      end
    end

    # Finds heroes via a given array of hero ids.
    # Returns an array of matching heroes
    def find_heroes_by_ids(hero_ids)
      hero_data = get_data("character_visual")
      hero_data.keep_if do |hero|
        hero_ids.include?(hero["id"])
      end
    end

    # Finds one stat hash via a given stat id.
    # Returns a matching stat hash or nil.
    def find_hero_stats_by_id(stat_id)
      stats_data = get_data("character_stat")
      stats_data.find do |stats|
        stats["id"] == stat_id
      end
    end

    # Finds one berry stat hash via a given berry stat id
    # Returns a matching berry stat hash or nil.
    def find_berry_stats_by_id(berry_stat_id)
      berry_stats_data = get_data("character_addstatmax")
      berry_stats_data.find do |berry_stats|
        berry_stats["id"] == berry_stat_id
      end
    end

    # Finds berries whose names match a given query.
    # Checks if the query can be converted to a regex and sends to the appropriate method.
    # Returns an array of matching berry hashes.
    def find_berries_by_name(query)
      regex = string_to_regex(query)
      regex ? find_berries_by_name_regex(regex) : find_berries_by_name_substring(query)
    end

    # Finds berries whose names contain a given substring.
    # Returns an array of matching berry hashes.
    def find_berries_by_name_substring(substr)
      berry_data = get_data("addstatitem")
      berry_data.keep_if do |berry|
        CQ::TEXT[berry["name"]].to_s.downcase.include?(substr.downcase)
      end
    end

    # Finds berries whose names match a given regex.
    # Returns an array of matching berry hashes.
    def find_berries_by_name_regex(regex)
      berry_data = get_data("addstatitem")
      berry_data.keep_if do |berry|
        CQ::TEXT[berry["name"]].to_s =~ regex
      end
    end

    # Finds weapons whose names match a given query.
    # Checks if the query can be converted to a regex and sends to the appropriate method.
    # Returns an array of matching weapon hashes.
    def find_weapons_by_name(query)
      regex = string_to_regex(query)
      regex ? find_weapons_by_name_regex(regex) : find_weapons_by_name_substring(query)
    end

    # Finds weapons whose names contain a given substring.
    # Returns an array of matching weapon hashes.
    def find_weapons_by_name_substring(substr)
      weapon_data = get_data("weapon")
      weapon_data.keep_if do |weapon|
        weapon["type"] == "HERO" && CQ::TEXT[weapon["name"]].to_s.downcase.include?(substr.downcase)
      end
    end

    # Finds weapons whose names match a given regex.
    # Returns an array of matching weapon hashes.
    def find_weapons_by_name_regex(regex)
      weapon_data = get_data("weapon")
      weapon_data.keep_if do |weapon|
        weapon["type"] == "HERO" && CQ::TEXT[weapon["name"]].to_s =~ regex
      end
    end

    # Finds skills whose names match a given query.
    # Checks if the query can be converted to a regex and sends to the appropriate method.
    # Returns an array of matching skill hashes.
    def find_skills_by_name(query)
      regex = string_to_regex(query)
      regex ? find_skills_by_name_regex(regex) : find_skills_by_name_substring(query)
    end

    # Finds skills whose names contain a given substring.
    # Returns an array of matching skill hashes.
    def find_skills_by_name_substring(substr)
      skill_data = get_data("spskill")
      skill_data.keep_if do |skill|
        CQ::TEXT[skill["name"]].to_s.downcase.include?(substr.downcase)
      end
    end

    # Finds skills whose names match a given regex.
    # Returns an array of matching skill hashes.
    def find_skills_by_name_regex(regex)
      skill_data = get_data("spskill")
      skill_data.keep_if do |skill|
        CQ::TEXT[skill["name"]].to_s =~ regex
      end
    end

    # Finds breads whose names match a given query.
    # Checks if the query can be converted to a regex and sends to the appropriate method.
    # Returns an array of matching bread hashes.
    def find_breads_by_name(query)
      regex = string_to_regex(query)
      regex ? find_breads_by_name_regex(regex) : find_breads_by_name_substring(query)
    end

    # Finds breads whose names contain a given substring.
    # Returns an array of matching bread hashes.
    def find_breads_by_name_substring(substr)
      bread_data = get_data("bread")
      bread_data.keep_if do |bread|
        CQ::TEXT[bread["name"]].to_s.downcase.include?(substr.downcase)
      end
    end

    # Finds breads whose names match a given regex.
    # Returns an array of matching bread hashes.
    def find_breads_by_name_regex(regex)
      bread_data = get_data("bread")
      bread_data.keep_if do |bread|
        CQ::TEXT[bread["name"]].to_s =~ regex
      end
    end

    # Reads a file, converts it to json, and grabs the relevant data within.
    # Returns the converted json data.
    def get_data(type)
      json = JSON.parse(File.read("data/get_#{type}.txt"))
      json[type]
    rescue
      nil
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
end
