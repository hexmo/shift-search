module ShiftSearch
  module Search
    class Runner
      def initialize(data)
        @data = data
      end

      def run(query)
        results = @data.select do |client|
          client["full_name"].to_s.downcase.include?(query.downcase)
        end

        if results.any?
          results.each { |r| pp "#{r['id']}: #{r['full_name']} (#{r['email']})" }
        else
          pp "No matches found for '#{query}'"
        end
      end
    end
  end
end
