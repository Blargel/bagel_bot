class CQ
  class Faction < Sequel::Model(:factions)
    unrestrict_primary_key
    one_to_many :heroes

    dataset_module do
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
  end
end
