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

      "Hero Name - #{hero_name} | " +
      "Class - #{hero_stars}☆ #{hero_class} | " +
      "Faction - #{hero_faction} | " +
      "How to get - #{hero_howtoget} | " +
      "Gender - #{hero_gender} | " +
      "Background - #{hero_desc}"
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

      "Hero Name - #{hero_name} | Class - #{hero_stars}☆ #{hero_class} | #{block_text}"
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

      "Hero Name - #{hero_name} | Class - #{hero_stars}☆ #{hero_class} | #{passive_text}"
    end

    # Message formatter for the !skill command
    def formatted_skill_message(query, level, skill)
      return "No skill names match \"#{query}\" and level #{level}!" if skill.nil?

      skill_name  = CQ::TEXT[skill["name"]].to_s.gsub("\n", " ")
      skill_level = skill["level"].to_s
      skill_desc  = CQ::TEXT[skill["desc"]].to_s.gsub("\n", " ")
      skill_great = "#{(skill["huge"]*100).to_i}%"
      skill_cost  = skill["cost"].map { |resource| "#{resource["value"]} #{resource["type"].capitalize}" }
      skill_cost  = skill_cost.join(", ")

      "#{skill_name} Level #{skill_level} | Great Rate - #{skill_great} | Cost - #{skill_cost} | Description - #{skill_desc}"
    end
  end
end
