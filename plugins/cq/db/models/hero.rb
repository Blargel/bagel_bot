class CQ
  class Hero < Sequel::Model(:heroes)
    unrestrict_primary_key
    many_to_many :weapons, :join_table => :weapons_heroes

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
        exact_match  = Regexp.new("^#{Regexp.quote(substr)}$", true)
        exact_word   = Regexp.new("(^|\\s)#{Regexp.quote(substr)}($|\\s)", true)
        string_start = Regexp.new("^#{Regexp.quote(substr)}", true)
        word_start   = Regexp.new("\\s#{Regexp.quote(substr)}", true)
        other        = Regexp.new(Regexp.quote(substr), true)

        where(Sequel.|(
          {:name => exact_match},
          {:name => exact_word},
          {:name => string_start},
          {:name => word_start},
          {:name => other}
        ))
          .order(Sequel.lit(
            "CASE WHEN \"name\" ~* ? THEN 1 " +
              "WHEN \"name\" ~* ? THEN 2 " +
              "WHEN \"name\" ~* ? THEN 3 " +
              "WHEN \"name\" ~* ? THEN 4 " +
              "ELSE 5 END",
            exact_match.source,
            exact_word.source,
            string_start.source,
            word_start.source
          ))
      end

      def filter_name_by_regex(regex)
        where(:name => regex)
      end
    end

    def stats(level, bread, with_berry)
      {
        "ha"  => calculate_growth_stat(level, bread, with_berry, ha_initial, ha_growth, berry_ha),
        "hp"  => calculate_growth_stat(level, bread, with_berry, hp_initial, hp_growth, berry_hp),
        "cc"  => calculate_percent_stat(with_berry, cc, berry_cc),
        "arm" => calculate_growth_stat(level, bread, with_berry, arm_initial, arm_growth, berry_arm),
        "res" => calculate_growth_stat(level, bread, with_berry, res_initial, res_growth, berry_res),
        "cd"  => calculate_percent_stat(with_berry, cd, berry_cd),
        "acc" => calculate_percent_stat(with_berry, acc, berry_acc),
        "eva" => calculate_percent_stat(with_berry, eva, berry_eva)
      }
    end

    private

    def calculate_growth_stat(level, bread, with_berry, initial, growth, extra)
      result = (initial + growth*(level-1)) * (1 + bread.to_f/10)
      result += extra if extra && with_berry
      result.round(1)
    end

    def calculate_percent_stat(with_berry, initial, extra)
      result = initial
      result += extra if extra && with_berry
      (result*100).round(1)
    end
  end
end
