class CQ
  class Berry < Sequel::Model(:berries)
    unrestrict_primary_key

    dataset_module do
      def filter_stars(stars)
        return self unless stars
        where(:stars => stars)
      end

      def filter_name(query)
        if query.kind_of?(Regexp)
          filter_name_by_regex(query)
        else
          filter_name_by_substring(query)
        end
      end

      def filter_name_by_substring(substr)
        regex = Regexp.new(Regexp.quote(substr), true)
        filter_name_by_regex(regex)
      end

      def filter_name_by_regex(regex)
        where(:name => regex)
      end
    end

    def stat
      case stat_type
      when /Ratio/, "All"
        "#{(stat_value*100).to_i}% #{stat_type_name}"
      when "Accuracy", "CriticalDamage", "CriticalChance", "Dodge"
        "#{(stat_value*100).round(1)} #{stat_type_name}"
      when "Armor", "AttackPower", "HP", "Resistance"
        "#{stat_value.round(1)} #{stat_type_name}"
      when "Great"
        "None"
      end
    end
  end
end
