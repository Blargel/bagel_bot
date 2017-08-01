class CQ
  class ChampionSkill < Sequel::Model(:champion_skills)
    unrestrict_primary_key
    many_to_one :champion

    dataset_module do
      def filter_champion_id(champion_id)
        return self unless champion_id
        where(champion_id: champion_id)
      end

      def filter_type(type)
        return self unless type
        where(type: type)
      end
      
      def filter_level(level)
        return self unless level
        where(level: level)
      end
    end
  end
end
