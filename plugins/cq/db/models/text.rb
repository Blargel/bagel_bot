class CQ
  class Text < Sequel::Model(:text)
    unrestrict_primary_key

    dataset_module do
      def filter_matches(query)
        if query.kind_of?(Regexp)
          filter_matches_by_regex(query)
        else
          filter_matches_by_substring(query)
        end
      end

      def filter_matches_by_substring(substr)
        regex = Regexp.new(Regexp.quote(substr), true)
        filter_matches_by_regex(regex)
      end

      def filter_matches_by_regex(regex)
        where(:id => regex).or(:content => regex)
      end
    end
  end
end
