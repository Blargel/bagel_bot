# encoding: utf-8

class CQ
  module MessageFormatter
    # Message formatter for the !text command
    def formatted_text_message(query, num, text)
      return "No matches found for #{query}!" if text.empty?

      match_count  = text.count
      text_id      = text[num-1][0].to_s.gsub("\n", " ")
      text_content = text[num-1][1].to_s.gsub("\n", " ")

      "[#{num}/#{match_count}] #{text_id} - #{text_content}"
    end

    # Message formatter for the !find command
    def formatted_find_message(type, query, results)
      return "No #{type} results for \"#{query}\"!" if results.empty?

      names = results.map { |r| TEXT[r["name"]].to_s.gsub("\n", " ") }
      names.uniq!

      count = names.count
      names = names.first(50).join(", ")

      "\x02(#{count} result#{"s" if count > 1} found#{", displaying first 50" if count > 50})\x02 - #{names}"
    end

    # Message formatter for the !hero command
    def formatted_hero_message(query, stars, hero, hero_stats)
      return "No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!" if hero_stats.nil?

      hero_faction  = if hero["domain"].nil?
                        "None"
                      elsif hero["domain"] == "NONEGROUP"
                        CQ::TEXT["TEXT_CHAMP_DOMAIN_NONEGROUP_NAME"]
                      else
                        CQ::TEXT["TEXT_CHAMPION_DOMAIN_#{hero["domain"]}"]
                      end

      hero_name     = CQ::TEXT[hero["name"]].to_s.gsub("\n", " ")
      hero_stars    = hero_stats["grade"]
      hero_class    = hero["classid"].to_s.gsub("CLA_", "").capitalize
      hero_faction  = hero_faction.to_s.gsub("\n", " ")
      hero_howtoget = Array(hero["howtoget"]).join(", ")
      hero_gender   = hero["gender"].to_s.capitalize
      hero_desc     = CQ::TEXT[hero["desc"]].to_s.gsub("\n", " ")

      "#{hero_name}" +
        " | Class - #{hero_stars}☆ #{hero_class}" +
        " | Faction - #{hero_faction}" +
        " | How to get - #{hero_howtoget}" +
        " | Gender - #{hero_gender}" +
        " | Background - #{hero_desc}"
    end

    # Message formatter for the !block command
    def formatted_block_message(query, stars, hero, hero_stats)
      return "No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!" if hero_stats.nil?

      hero_name  = CQ::TEXT[hero["name"]].to_s.gsub("\n", " ")
      hero_stars = hero_stats["grade"]
      hero_class = hero["classid"].to_s.gsub("CLA_", "").capitalize
      block_name = CQ::TEXT[hero_stats["skill_name"]]
      block_desc = CQ::TEXT[hero_stats["skill_desc"]]
      block_text = block_name.nil? ? "This hero has no block skill." : "#{block_name.to_s.gsub("\n", " ")} - #{block_desc.to_s.gsub("\n", " ")}"

      "#{hero_name}" +
        " | Class - #{hero_stars}☆ #{hero_class}" +
        " | #{block_text}"
    end

    # Message formatter for the !passive command
    def formatted_passive_message(query, stars, hero, hero_stats)
      return "No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!" if hero_stats.nil?

      hero_name    = CQ::TEXT[hero["name"]].to_s.gsub("\n", " ")
      hero_stars   = hero_stats["grade"]
      hero_class   = hero["classid"].to_s.gsub("CLA_", "").capitalize
      passive_name = CQ::TEXT[hero_stats["skill_subname"]]
      passive_desc = CQ::TEXT[hero_stats["skill_subdesc"]]
      passive_text = passive_name.nil? ? "This hero has no passive." : "#{passive_name.to_s.gsub("\n", " ")} - #{passive_desc.to_s.gsub("\n", " ")}"

      "#{hero_name}" +
        " | Class - #{hero_stars}☆ #{hero_class}" +
        " | #{passive_text}"
    end

    # Message formatter for the !stats command
    def formatted_stats_message(query, stars, level, bread, berry, hero, hero_stats, berry_stats)
      return "No #{ stars.to_s + "☆ " if stars}hero's name matches \"#{query}\"!" if hero_stats.nil?

      stars ||= hero_stats["grade"]
      level ||= stars*10
      bread ||= stars-1
      berry = true if berry.nil?

      return "Error - Invalid star level: #{stars}." if stars && ![1,2,3,4,5,6].include?(stars)
      return "Error - Invalid level for #{stars}☆ hero: #{level}" if level && (level > stars*10 || level < 1)
      return "Error - Invalid training for #{stars}☆ hero: #{bread}" if bread && (bread > stars-1 || bread < 0)

      stats      = calculate_stats(level, bread, berry, hero_stats, berry_stats)
      hero_name  = CQ::TEXT[hero["name"]].to_s.gsub("\n", " ")
      berry_text = if stars == 6
                     berry ? " with berries" : " without berries "
                   else
                     ""
                   end

      "Level #{level} #{hero_name} +#{bread}#{berry_text}" +
        " - #{stats["ha"].round(1)} Atk Power" +
        " | #{stats["hp"].round(1)} HP" +
        " | #{(stats["cc"]*100).round(1)} Crit Chance" +
        " | #{stats["arm"].round(1)} Armor" +
        " | #{stats["res"].round(1)} Resistance" +
        " | #{(stats["cd"]*100).round(1)} Crit Dmg" +
        " | #{(stats["acc"]*100).round(1)} Accuracy" +
        " | #{(stats["eva"]*100).round(1)} Evasion"
    end

    # Message formatter for the !skill command
    def formatted_skill_message(query, level, skill)
      return "No skill names match \"#{query}\" and level #{level}!" if skill.nil?

      skill_name  = CQ::TEXT[skill["name"]].to_s.gsub("\n", " ")
      skill_level = skill["level"].to_i
      skill_desc  = CQ::TEXT[skill["desc"]].to_s.gsub("\n", " ")
      skill_great = "#{(skill["huge"]*100).to_i}%"
      skill_cost  = skill["cost"].map { |resource| "#{resource["value"]} #{resource["type"].capitalize}" }
      skill_cost  = skill_cost.join(", ")

      "#{skill_name} Level #{skill_level}" +
        " | Great - #{skill_great}" +
        " | Cost - #{skill_cost}" +
        " | Description - #{skill_desc}"
    end

    # Message formatter for the !bread command
    def formatted_bread_message(query, stars, bread)
      return "No #{ stars.to_s + "☆ " if stars}bread names match \"#{query}\"!" if bread.nil?

      bread_name     = CQ::TEXT[bread["name"]].to_s.gsub("\n", " ")
      bread_stars    = bread["grade"].to_i
      bread_training = bread["trainpoint"].to_s
      bread_great    = "#{(bread["critprob"]*100).to_i}%"
      bread_sell     = bread["sellprice"].to_s

      "#{bread_name}" +
        " | #{bread_stars}☆ Bread" +
        " | Training - #{bread_training}" +
        " | Great - #{bread_great}" +
        " | Sell Price - #{bread_sell}"
    end

    # Message formatter for the !berry command
    def formatted_berry_message(query, stars, berry)
      return "No #{ stars.to_s + "☆ " if stars}berry names match \"#{query}\"!" if berry.nil?

      berry_name      = CQ::TEXT[berry["name"]].to_s.gsub("\n", " ")
      berry_stars     = berry["grade"].to_i
      berry_type      = berry["type"].to_s
      berry_type_name = CQ::TEXT[berry["type_name"]]
      berry_value     = berry["add_stat_point"].to_f
      berry_great     = "#{(berry["great_prob"]*100).to_i}%"
      berry_eat       = berry["eat_price"].to_s
      berry_sell      = berry["sell_price"].to_s

      berry_stat = nil
      case berry_type
      when /Ratio/, "All"
        berry_stat = "#{(berry_value*100).to_i}% #{berry_type_name}"
      when "Accuracy", "CriticalDamage", "CriticalChance", "Dodge"
        berry_stat = "#{(berry_value*100).round(1)} #{berry_type_name}"
      when "Armor", "AttackPower", "HP", "Resistance"
        berry_stat = "#{berry_value.round(1)} #{berry_type_name}"
      when "Great"
        berry_stat = "None"
      end

      "#{berry_name}" +
        " | #{berry_stars}☆ Berry" +
        " | Stat - #{berry_stat}" +
        " | Great - #{berry_great}" +
        " | Eat Price - #{berry_eat}" +
        " | Sell Price - #{berry_sell}"
    end

    # Message formatter for the !weapon command
    def formatted_weapon_message(query, stars, weapon, weapon_bound_to)
      return "No #{ stars.to_s + "☆ " if stars}weapon names match \"#{query}\"!" if weapon.nil?

      weapon_name     = CQ::TEXT[weapon["name"]].to_s.gsub("\n", " ")
      weapon_stars    = weapon["grade"].to_i
      weapon_class    = weapon["categoryid"].to_s.gsub("CAT_", "").capitalize
      weapon_slot1    = weapon["convert_slot_1"].to_s.capitalize
      weapon_slot2    = weapon["convert_slot_2"].to_s.capitalize
      weapon_slot3    = weapon["convert_slot_3"].to_s.capitalize
      weapon_attack   = weapon["attdmg"].to_i
      weapon_speed    = weapon["attspd"].to_f.round(1)
      weapon_howtoget = Array(weapon["howtoget"]).join(", ")
      weapon_bound_to = weapon_bound_to.map { |hero| CQ::TEXT[hero["name"]].to_s.gsub("\n", " ") }
      weapon_bound_to = weapon_bound_to.join(", ")
      weapon_desc     = CQ::TEXT[weapon["desc"]].to_s.gsub("\n", " ")

      message = "#{weapon_name}" +
        " | #{weapon_stars}☆ #{weapon_class}" +
        " | Slots - #{weapon_slot1} #{weapon_slot2} #{weapon_slot3}" +
        " | Atk Power - #{weapon_attack}" +
        " | Atk Speed - #{weapon_speed}" +
        " | How to Get - #{weapon_howtoget}"

      message << " | Bound To - #{weapon_bound_to}" unless weapon_bound_to.empty?
      message << " | Ability - #{weapon_desc}" unless weapon_desc.empty?

      message
    end

    # Message formatter for the !highscore command with no params
    def formatted_highscore_message(heroes, hero_stats, berry_stats)
      reg_stats = ["ha", "hp", "cc", "arm", "res", "cd", "acc", "eva"]
      berry_stat_names = {
        "berryha" => "attack_power",
        "berryhp" => "hp",
        "berrycc" => "critical_chance",
        "berryarm" => "armor",
        "berryres" => "resistance",
        "berrycd" => "critical_damage",
        "berryacc" => "accuracy",
        "berryeva" => "dodge"
      }

      top_stats = {}
      hero_stats.each do |hero_stat|
        berry_stat = berry_stats.find { |b| b["id"] == hero_stat["addstat_max_id"] }
        calc_stats = calculate_stats(60, 5, true, hero_stat, berry_stat)

        reg_stats.each do |s|
          if top_stats[s].nil? || top_stats[s]["value"] < calc_stats[s]
            hero = heroes.find { |h| h["default_stat_id"] ==  hero_stat["id"] }

            top_stats[s] = {
              "hero" => CQ::TEXT[hero["name"]],
              "value" => calc_stats[s]
            }
          end
        end

        berry_stat_names.each do |k, v|
          if top_stats[k].nil? || top_stats[k]["value"] < berry_stat[v]
            hero = heroes.find { |h| h["default_stat_id"] ==  hero_stat["id"] }

            top_stats[k] = {
              "hero" => CQ::TEXT[hero["name"]],
              "value" => berry_stat[v]
            }
          end
        end
      end

      "Atk Power - #{top_stats["ha"]["hero"]} #{top_stats["ha"]["value"].round(1)}" +
        " | HP - #{top_stats["hp"]["hero"]} #{top_stats["hp"]["value"].round(1)}" +
        " | Crit Chance - #{top_stats["cc"]["hero"]} #{(top_stats["cc"]["value"]*100).round(1)}" +
        " | Armor - #{top_stats["arm"]["hero"]} #{top_stats["arm"]["value"].round(1)}" +
        " | Resistance - #{top_stats["res"]["hero"]} #{top_stats["res"]["value"].round(1)}" +
        " | Crit Dmg - #{top_stats["cd"]["hero"]} #{(top_stats["cd"]["value"]*100).round(1)}" +
        " | Accuracy - #{top_stats["acc"]["hero"]} #{(top_stats["acc"]["value"]*100).round(1)}" +
        " | Evasion - #{top_stats["eva"]["hero"]} #{(top_stats["eva"]["value"]*100).round(1)}"+
        "\nBerry Atk Power - #{top_stats["berryha"]["hero"]} #{top_stats["berryha"]["value"].round(1)}" +
        " | Berry HP - #{top_stats["berryhp"]["hero"]} #{top_stats["berryhp"]["value"].round(1)}" +
        " | Berry Crit Chance - #{top_stats["berrycc"]["hero"]} #{(top_stats["berrycc"]["value"]*100).round(1)}" +
        " | Berry Armor - #{top_stats["berryarm"]["hero"]} #{top_stats["berryarm"]["value"].round(1)}" +
        " | Berry Resistance - #{top_stats["berryres"]["hero"]} #{top_stats["berryres"]["value"].round(1)}" +
        " | Berry Crit Dmg - #{top_stats["berrycd"]["hero"]} #{(top_stats["berrycd"]["value"]*100).round(1)}" +
        " | Berry Accuracy - #{top_stats["berryacc"]["hero"]} #{(top_stats["berryacc"]["value"]*100).round(1)}" +
        " | Berry Evasion - #{top_stats["berryeva"]["hero"]} #{(top_stats["berryeva"]["value"]*100).round(1)}"
    end

    # Message formatter for the !highscore command_with the stat specified
    def fomatted_highscore_stat_message(heroes, hero_stats, berry_stats, stat)
      reg_stat_names = ["ha", "hp", "cc", "arm", "res", "cd", "acc", "eva"]
      berry_stat_names = {
        "berryha" => "attack_power",
        "berryhp" => "hp",
        "berrycc" => "critical_chance",
        "berryarm" => "armor",
        "berryres" => "resistance",
        "berrycd" => "critical_damage",
        "berryacc" => "accuracy",
        "berryeva" => "dodge"
      }
      valid_stats = reg_stat_names + berry_stat_names.keys
      return "Error - Invalid stat: #{stat}. Valid stats: #{valid_stats.join(", ")}" unless valid_stats.include?(stat.downcase)

      top_stats = []
      hero_stats.each do |hero_stat|
        hero = heroes.find { |h| h["default_stat_id"] ==  hero_stat["id"] }
        berry_stat = berry_stats.find { |b| b["id"] == hero_stat["addstat_max_id"] }

        value = nil
        if reg_stat_names.include?(stat)
          calc_stats = calculate_stats(60, 5, true, hero_stat, berry_stat)
          value = calc_stats[stat]
          value *= 100 if ["cc", "cd", "acc", "eva"].include?(stat)
        else
          value = berry_stat[berry_stat_names[stat]]
          value *= 100 if ["berrycc", "berrycd", "berryacc", "berryeva"].include?(stat)
        end

        top_stats << {
          "hero" => CQ::TEXT[hero["name"]],
          "value" => value.round(1)
        }
      end
      top_stats.sort! { |a, b| b["value"] <=> a["value"] }
      top_stats = top_stats.first(10)

      "#{top_stats[0]["hero"]} #{top_stats[0]["value"]}" +
        " | #{top_stats[1]["hero"]} #{top_stats[1]["value"]}" +
        " | #{top_stats[2]["hero"]} #{top_stats[2]["value"]}" +
        " | #{top_stats[3]["hero"]} #{top_stats[3]["value"]}" +
        " | #{top_stats[4]["hero"]} #{top_stats[4]["value"]}" +
        " | #{top_stats[5]["hero"]} #{top_stats[5]["value"]}" +
        " | #{top_stats[6]["hero"]} #{top_stats[6]["value"]}" +
        " | #{top_stats[7]["hero"]} #{top_stats[7]["value"]}" +
        " | #{top_stats[8]["hero"]} #{top_stats[8]["value"]}" +
        " | #{top_stats[9]["hero"]} #{top_stats[9]["value"]}"
    end

    # Message formatter for the !highscore command with stat and class specified
    def formatted_highscore_stat_class_message(heroes, hero_stats, berry_stats, stat, hero_class)
      reg_stat_names = ["ha", "hp", "cc", "arm", "res", "cd", "acc", "eva"]
      berry_stat_names = {
        "berryha" => "attack_power",
        "berryhp" => "hp",
        "berrycc" => "critical_chance",
        "berryarm" => "armor",
        "berryres" => "resistance",
        "berrycd" => "critical_damage",
        "berryacc" => "accuracy",
        "berryeva" => "dodge"
      }
      valid_stats = reg_stat_names + berry_stat_names.keys
      valid_classes = ["warrior", "paladin", "archer", "hunter", "wizard", "priest"]
      return "Error - Invalid stat: #{stat}. Valid stats: #{valid_stats.join(", ")}" unless valid_stats.include?(stat.downcase)
      return "Error - Invalid class: #{hero_class}. Valid classes: #{valid_classes.join(", ")}" unless valid_classes.include?(hero_class.downcase)

      hero_class = "CLA_" + hero_class.upcase

      top_stats = []
      hero_stats.each do |hero_stat|
        hero = heroes.find { |h| h["default_stat_id"] ==  hero_stat["id"] }
        next unless hero["classid"] == hero_class

        berry_stat = berry_stats.find { |b| b["id"] == hero_stat["addstat_max_id"] }

        value = nil
        if reg_stat_names.include?(stat)
          calc_stats = calculate_stats(60, 5, true, hero_stat, berry_stat)
          value = calc_stats[stat]
          value *= 100 if ["cc", "cd", "acc", "eva"].include?(stat)
        else
          value = berry_stat[berry_stat_names[stat]]
          value *= 100 if ["berrycc", "berrycd", "berryacc", "berryeva"].include?(stat)
        end

        top_stats << {
          "hero" => CQ::TEXT[hero["name"]],
          "value" => value.round(1)
        }
      end
      top_stats.sort! { |a, b| b["value"] <=> a["value"] }
      top_stats = top_stats.first(10)

      "#{top_stats[0]["hero"]} #{top_stats[0]["value"]}" +
        " | #{top_stats[1]["hero"]} #{top_stats[1]["value"]}" +
        " | #{top_stats[2]["hero"]} #{top_stats[2]["value"]}" +
        " | #{top_stats[3]["hero"]} #{top_stats[3]["value"]}" +
        " | #{top_stats[4]["hero"]} #{top_stats[4]["value"]}" +
        " | #{top_stats[5]["hero"]} #{top_stats[5]["value"]}" +
        " | #{top_stats[6]["hero"]} #{top_stats[6]["value"]}" +
        " | #{top_stats[7]["hero"]} #{top_stats[7]["value"]}" +
        " | #{top_stats[8]["hero"]} #{top_stats[8]["value"]}" +
        " | #{top_stats[9]["hero"]} #{top_stats[9]["value"]}"
    end

    # Calculate all stats for a hero with the given data
    def calculate_stats(level, bread, berry, hero_stats, berry_stats)
      berry = berry_stats && berry
      {
        "ha"  => calculate_stat(level, bread, hero_stats["initialattdmg"], hero_stats["growthattdmg"], berry ? berry_stats["attack_power"] : 0),
        "hp"  => calculate_stat(level, bread, hero_stats["initialhp"], hero_stats["growthhp"], berry ? berry_stats["hp"] : 0),
        "cc"  => hero_stats["critprob"] + (berry ? berry_stats["critical_chance"] : 0),
        "arm" => calculate_stat(level, bread, hero_stats["defense"], hero_stats["growthdefense"], berry ? berry_stats["armor"] : 0),
        "res" => calculate_stat(level, bread, hero_stats["resist"], hero_stats["growthresist"], berry ? berry_stats["resistance"] : 0),
        "cd"  => hero_stats["critpower"] + (berry ? berry_stats["critical_damage"] : 0),
        "acc" => hero_stats["hitrate"] + (berry ? berry_stats["accuracy"] : 0),
        "eva" => hero_stats["dodgerate"] + (berry ? berry_stats["dodge"] : 0)
      }
    end

    # Calculate one stat with the given data
    def calculate_stat(level, bread, start, growth, berry_stat)
      ((start + growth*(level-1)) * (1 + bread.to_f/10) + berry_stat)
    end
  end
end
