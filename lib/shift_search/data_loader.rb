require "json"

module ShiftSearch
  class DataLoader
    def self.load(file_path)
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit 1
      end

      # Read first character in binary mode to check if file is likely JSON
      first_char = File.open(file_path, "rb") { |f| f.read(1) }

      unless ["{", "["].include?(first_char)
        puts "File does not appear to be JSON. Expected '{' or '[', but got '#{first_char.inspect}'"
        exit 1
      end

      begin
        raw = File.read(file_path, encoding: "UTF-8")
        JSON.parse(raw)
      rescue JSON::ParserError => e
        puts "Failed to parse JSON: #{e.message}"
        exit 1
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
        puts "Encoding error while reading file: #{e.message}"
        exit 1
      end
    end
  end
end
