require "json"

module ShiftSearch
  class DataLoader
    def self.load(file_path)
      unless File.exist?(file_path)
        raise "File not found: #{file_path}"
      end

      # Read first character in binary mode to check if file is likely JSON
      first_char = File.open(file_path, "rb") { |f| f.read(1) }

      unless ["{", "["].include?(first_char)
        raise JSON::ParserError, "File does not appear to be JSON. Expected '{' or '[', but got '#{first_char.inspect}'"
      end

      begin
        raw = File.read(file_path, encoding: "UTF-8")
        JSON.parse(raw)
      rescue JSON::ParserError => e
        raise JSON::ParserError, "Failed to parse JSON: #{e.message}"
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
        raise JSON::ParserError, "Encoding error while reading file: #{e.message}"
      end
    end
  end
end
