module ShiftSearch
  module Duplicates
    class Runner
      def initialize(data)
        @data = data
      end

      def run
        grouped = @data.group_by { |c| c["email"] }
        duplicates = grouped.select { |_, group| group.size > 1 }

        if duplicates.empty?
          pp "No duplicate emails found."
        else
          duplicates.each do |email, clients|
            pp "Duplicate email: #{email}"
            clients.each { |c| pp "- #{c['id']}: #{c['full_name']}" }
          end
        end
      end
    end
  end
end
