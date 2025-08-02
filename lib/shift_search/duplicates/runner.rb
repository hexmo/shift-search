require_relative "../output_formatter"

module ShiftSearch
  module Duplicates
    class Runner
      def initialize(data)
        @data = data
      end

      def run(format, output: nil)
        grouped = @data.group_by { |c| c["email"].to_s.strip.downcase }
                      .reject { |email, _| email.empty? }
        
        duplicates = grouped.select { |_, group| group.size > 1 }

        if duplicates.empty?
          puts "No duplicate emails found."
        else
          flat_duplicates = duplicates.flat_map do |email, clients|
            clients.map { |c| c.merge("duplicate_email" => c["email"]) }
          end

          ShiftSearch::OutputFormatter.output(flat_duplicates, format: format, output_path: output)
        end
      end
    end
  end
end
