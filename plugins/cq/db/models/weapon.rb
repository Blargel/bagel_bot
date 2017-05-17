class CQ
  class Weapon < Sequel::Model(:weapons)
    unrestrict_primary_key
    many_to_many :heroes, :join_table => :weapons_heroes

    dataset_module do
      def filter_stars(stars)
        return self unless stars
        where(Sequel.qualify("weapons", "stars") => stars)
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

      def filter_bound_to(query)
        if query.kind_of?(Regexp)
          filter_bound_to_by_regex(query)
        else
          filter_bound_to_by_substring(query)
        end
      end

      def filter_bound_to_by_substring(substr)
        regex = Regexp.new(Regexp.quote(substr), true)
        filter_bound_to_by_regex(regex)
      end

      def filter_bound_to_by_regex(regex)
        eager_graph(:heroes)
          .where(Sequel.qualify("heroes", "name") => regex)
      end

      def filter_name_or_bound_to(query)
        if query.kind_of?(Regexp)
          filter_name_or_bound_to_by_regex(query)
        else
          filter_name_or_bound_to_by_substring(query)
        end
      end

      def filter_name_or_bound_to_by_substring(substr)
        regex = Regexp.new(Regexp.quote(substr), true)
        filter_name_or_bound_to_by_regex(regex)
      end

      def filter_name_or_bound_to_by_regex(regex)
        eager_graph(:heroes)
          .where(Sequel.qualify("weapons", "name") => regex)
          .or(Sequel.qualify("heroes", "name") => regex)
          .order(Sequel.lit(
            "CASE WHEN \"heroes\".\"name\" ~* ? THEN 1 ELSE 2 END",
            regex.source,
          ))
      end
    end

    def bound_to
      heroes.empty? ? nil : heroes.map(&:name).join(", ")
    end
  end
end
