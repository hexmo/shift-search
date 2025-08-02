require "json"

module ShiftSearch
  class DataLoader
    # Perform validation to ensure the data is in the JSON format
    def self.load(file_path)
      JSON.parse(File.read(file_path))
    rescue Errno::ENOENT
      pp "File not found: #{file_path}"
      exit 1
    rescue JSON::ParserError => e
      pp "Failed to parse JSON: #{e.message}"
      exit 1
    end
  end
end
