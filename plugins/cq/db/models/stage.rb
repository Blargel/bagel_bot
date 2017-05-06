class CQ
  class Stage < Sequel::Model(:stages)
    unrestrict_primary_key
    one_to_many :stages_monsters

    def self.find_by_code(code)
      where(:code => code.downcase).first
    end

    def monsters
      stages_monsters.map do |stages_monster|
        {
          :monster => stages_monster.monster,
          :level   => stages_monster.level
        }
      end
    end

    def monster_list
      monsters.map do |m|
        "Lvl #{m[:level]} #{m[:monster].name}"
      end
    end

    def dropped_bread
      min_bread_stars > 0 ? "#{min_bread_stars}~#{max_bread_stars}☆" : "None"
    end

    def dropped_weapons
      !weapon_types.empty? ? "#{min_weapon_stars}~#{max_weapon_stars}☆ #{weapon_types}" : "None"
    end
  end
end
