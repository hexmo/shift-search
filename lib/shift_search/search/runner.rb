module ShiftSearch
  module Search
    class Runner
      def initialize(data)
        @data = data
      end

      def run(query, key)
        results = @data.select do |client|
          client[key].to_s.downcase.include?(query.downcase)
        end

        if results.any?
          results.each do |r|
            puts "#{r['id']}: #{r[key]} (#{r['email']})"
          end
        else
          puts "No matches found for '#{query}' in '#{key}'"
        end
      end
    end
  end
end
