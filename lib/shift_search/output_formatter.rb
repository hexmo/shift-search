require "json"
require "csv"

module ShiftSearch
  module OutputFormatter
    def self.output(data, format:, output_path: nil)
      formatted =
        case format
        when "json"
          JSON.pretty_generate(data)
        when "csv"
          to_csv(data)
        else
          raise "Unsupported format: #{format}"
        end

      if output_path
        File.write(output_path, formatted)
        puts "Results saved to #{output_path}"
      else
        puts formatted
      end
    end

    def self.to_csv(data)
      return "" if data.empty?

      CSV.generate(headers: true) do |csv|
        csv << data.first.keys
        data.each do |row|
          csv << row.values
        end
      end
    end
  end
end
