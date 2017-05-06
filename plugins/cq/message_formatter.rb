# encoding: utf-8

class CQ
  module MessageFormatter
    # Message formatter for the !text command
    def formatted_text_message(num, texts)
      match_count  = texts.count
      num          = match_count if num > match_count
      text         = texts[num-1]

      "[#{num}/#{match_count}] #{text.id} - #{text.content}"
    end

    # Message formatter for the !find command
    def formatted_find_message(results)
      names = results.map(&:name).uniq
      count = names.count
      names = names.first(50).join(", ")
      over_50_text = count > 50 ? ", displaying first 50" : ""

      "\x02(#{count} result#{"s" if count > 1} found#{over_50_text})\x02 - #{names}"
    end

    # Message formatter for the !hero command
    def formatted_hero_message(hero)
      "#{hero.name}" +
        " | Class - #{hero.stars}☆ #{hero.hero_class}" +
        " | Faction - #{hero.faction}" +
        " | How to get - #{hero.how_to_get}" +
        " | Gender - #{hero.gender}" +
        " | Background - #{hero.background}"
    end

    # Message formatter for the !block command
    def formatted_block_message(hero)
      "#{hero.name}" +
        " | Class - #{hero.stars}☆ #{hero.hero_class}" +
        " | #{hero.block_name} - #{hero.block_desc}"
    end

    # Message formatter for the !passive command
    def formatted_passive_message(hero)
      "#{hero.name}" +
        " | Class - #{hero.stars}☆ #{hero.hero_class}" +
        " | #{hero.passive_name} - #{hero.passive_desc}"
    end

    # Message formatter for the !stats command
    def formatted_stats_message(hero, level, bread, with_berry)
      stats = hero.stats(level, bread, with_berry)

      berry_text = if hero.stars == 6
                     with_berry ? " with berries" : " without berries "
                   else
                     ""
                   end

      "Lvl #{level} #{hero.name} +#{bread}#{berry_text}" +
        " | #{stats["ha"]} Atk Power" +
        " | #{stats["hp"]} HP" +
        " | #{stats["cc"]} Crit Chance" +
        " | #{stats["arm"]} Armor" +
        " | #{stats["res"]} Resistance" +
        " | #{stats["cd"]} Crit Dmg" +
        " | #{stats["acc"]} Accuracy" +
        " | #{stats["eva"]} Evasion"
    end

    # Message formatter for the !skill command
    def formatted_skill_message(skill)
      "#{skill.name} Lvl #{skill.level}" +
        " | Great - #{skill.great_rate}%" +
        " | Cost - #{skill.gold_cost} Gold, #{skill.honor_cost} Honor" +
        " | Description - #{skill.description}"
    end

    # Message formatter for the !bread command
    def formatted_bread_message(bread)
      "#{bread.name}" +
        " | #{bread.stars}☆ Bread" +
        " | Training - #{bread.training}" +
        " | Great - #{bread.great_rate}" +
        " | Sell Price - #{bread.sell_price}"
    end

    # Message formatter for the !berry command
    def formatted_berry_message(berry)
      "#{berry.name}" +
        " | #{berry.stars}☆ Berry" +
        " | Stat - #{berry.stat}" +
        " | Great - #{berry.great_rate}%" +
        " | Eat Price - #{berry.eat_price}" +
        " | Sell Price - #{berry.sell_price}"
    end

    # Message formatter for the !weapon command
    def formatted_weapon_message(weapon)
      message = "#{weapon.name}" +
        " | #{weapon.stars}☆ #{weapon.weapon_class}" +
        " | Slots - #{weapon.slot1}, #{weapon.slot2}, #{weapon.slot3}" +
        " | Atk Power - #{weapon.attack_power}" +
        " | Atk Speed - #{weapon.attack_speed}" +
        " | How to Get - #{weapon.how_to_get}"

      message << " | Bound To - #{weapon.bound_to}" if weapon.bound_to
      message << " | Ability - #{weapon.ability}" if weapon.ability

      message
    end

    # Message formatter for the !highscore command
    def formatted_highscore_message(results, stat)
      if results.kind_of?(Hash)
        formatted_highscore_without_params_message(results)
      elsif results.kind_of?(Array)
        formatted_highscore_with_params_message(results, stat)
      else
        raise
      end
    end

    # Message formatter for the !highscore command with params
    def formatted_highscore_without_params_message(results)
      "Atk Power - #{results["ha"][:name]} #{results["ha"][:value].round(1)}" +
        " | HP - #{results["hp"][:name]} #{results["hp"][:value].round(1)}" +
        " | Crit Chance - #{results["cc"][:name]} #{(results["cc"][:value]*100).round(1)}" +
        " | Armor - #{results["arm"][:name]} #{results["arm"][:value].round(1)}" +
        " | Resistance - #{results["res"][:name]} #{results["res"][:value].round(1)}" +
        " | Crit Dmg - #{results["cd"][:name]} #{(results["cd"][:value]*100).round(1)}" +
        " | Accuracy - #{results["acc"][:name]} #{(results["acc"][:value]*100).round(1)}" +
        " | Evasion - #{results["eva"][:name]} #{(results["eva"][:value]*100).round(1)}"+
        "\nBerry Atk Power - #{results["berry_ha"][:name]} #{results["berry_ha"][:value].round(1)}" +
        " | Berry HP - #{results["berry_hp"][:name]} #{results["berry_hp"][:value].round(1)}" +
        " | Berry Crit Chance - #{results["berry_cc"][:name]} #{(results["berry_cc"][:value]*100).round(1)}" +
        " | Berry Armor - #{results["berry_arm"][:name]} #{results["berry_arm"][:value].round(1)}" +
        " | Berry Resistance - #{results["berry_res"][:name]} #{results["berry_res"][:value].round(1)}" +
        " | Berry Crit Dmg - #{results["berry_cd"][:name]} #{(results["berry_cd"][:value]*100).round(1)}" +
        " | Berry Accuracy - #{results["berry_acc"][:name]} #{(results["berry_acc"][:value]*100).round(1)}" +
        " | Berry Evasion - #{results["berry_eva"][:name]} #{(results["berry_eva"][:value]*100).round(1)}"
    end

    # Message formatter for the !highscore command with params
    def formatted_highscore_with_params_message(results, stat)
      results.map! do |result|
        value = result[:value]
        value *= 100 if ["cc", "cd", "acc", "eva", "berry_cc", "berry_cd", "berry_acc", "berry_eva"].include?(stat)
        value = value.round(1)
        "#{result[:name]} #{value}"
      end

      results.join(" | ")
    end

    # Message formatter for the !stage command
    def formatted_stage_message(stage)
      "#{stage.name}" +
        " | Cost - #{stage.meat_cost} meat" +
        " | Dropped Bread - #{stage.dropped_bread}" +
        " | Dropped Weapons - #{stage.dropped_weapons}" +
        " | Enemies - #{stage.monster_list.join(", ")}"
    end

    # Message formatter for the !monstats command
    def formatted_monsterstats_message(monster, level)
      stats = monster.stats(level)
      "Lvl #{level} #{monster.name}" +
        " | #{stats["ha"]} Atk Power" +
        " | #{stats["hp"]} HP" +
        " | #{stats["cc"]} Crit Chance" +
        " | #{stats["arm"]} Armor" +
        " | #{stats["res"]} Resistance" +
        " | #{stats["cd"]} Crit Dmg" +
        " | #{stats["acc"]} Accuracy" +
        " | #{stats["eva"]} Evasion" +
        " | #{stats["apen"]} Armor Penetration" +
        " | #{stats["rpen"]} Resistance Penetration" +
        " | #{stats["dr"]}% Dmg Reduction"
    end

    # Message formatter for the !skin command
    def formatted_skin_message(skin)
      "#{skin.name}" +
        " | Sell Price - #{skin.sell_price} Gold" +
        " | Stats - #{skin.stats}"
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
