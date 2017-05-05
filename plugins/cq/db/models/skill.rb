class CQ
  class Skill < Sequel::Model(:skills)
    unrestrict_primary_key

    dataset_module do
      def filter_level(level)
        return self unless level
        where(:level => level)
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
  end
end
