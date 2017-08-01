class CQ
  class Monster < Sequel::Model(:monsters)
    unrestrict_primary_key
    one_to_many :stages_monsters

    dataset_module do
      def filter_name(query)
        if query.kind_of?(Regexp)
          filter_name_by_regex(query)
        else
          filter_name_by_substring(query)
        end
      end

      def filter_name_by_substring(substr)
        exact_match  = "^#{substr}$"
        exact_word   = "(^|\\s)#{Regexp.quote(substr)}($|\\s)"
        string_start = "^#{Regexp.quote(substr)}"
        word_start   = "\\s#{Regexp.quote(substr)}"
        other        = Regexp.quote(substr)

        where(Sequel.|(
          {:name => Regexp.new(exact_match, true)},
          {:name => Regexp.new(exact_word, true)},
          {:name => Regexp.new(string_start, true)},
          {:name => Regexp.new(word_start, true)},
          {:name => Regexp.new(other, true)}
        ))
          .order(Sequel.lit(
            "CASE WHEN \"name\" ~* ? THEN 1 " +
              "WHEN \"name\" ~* ? THEN 2 " +
              "WHEN \"name\" ~* ? THEN 3 " +
              "WHEN \"name\" ~* ? THEN 4 " +
              "ELSE 5 END",
            exact_match,
            exact_word,
            string_start,
            word_start
          ))
      end

      def filter_name_by_regex(regex)
        where(:name => regex)
      end
    end

    def stats(level)
      {
        "ha"  => calculate_growth_stat(level, ha_initial, ha_growth),
        "hp"  => calculate_growth_stat(level, hp_initial, hp_growth),
        "cc"  => calculate_percent_stat(cc),
        "arm" => calculate_growth_stat(level, arm_initial, arm_growth),
        "res" => calculate_growth_stat(level, res_initial, res_growth),
        "cd"  => calculate_percent_stat(cd),
        "acc" => calculate_percent_stat(acc),
        "eva" => calculate_percent_stat(eva),
        "apen" => arm_pen.round,
        "rpen" => res_pen.round,
        "dr" => calculate_percent_stat(dr),
        "kb_resist" => kb_resist
      }
    end

    private

    def calculate_growth_stat(level, initial, growth)
      result = initial + growth*(level-1)
      result.round(1)
    end

    def calculate_percent_stat(initial)
      (initial*100).round(1)
    end
  end
end
