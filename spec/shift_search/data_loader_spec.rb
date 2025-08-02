require "spec_helper"
require "json"

RSpec.describe ShiftSearch::DataLoader do
  let(:file_path) { "data/clients.json" }
  let(:invalid_path) { "data/invalid_path.json" }
  let(:empty_file) { "data/empty.json" }
  let(:image_file) { "data/image.png" }

  describe ".load" do
    it "loads JSON data from a valid file" do
      data = described_class.load(file_path)
      expect(data).to be_an(Array)
      expect(data.first).to include("full_name", "email")
    end

    it "raises RuntimeError when file not found" do
      expect { described_class.load(invalid_path) }
        .to raise_error(RuntimeError, /File not found/)
    end

    it "raises JSON::ParserError when file isn't valid JSON file" do
      expect { described_class.load(image_file) }
        .to raise_error(JSON::ParserError, /Expected '\{' or '\['/)
    end

    it "raises JSON::ParserError on empty file" do
      expect { described_class.load(empty_file) }
        .to raise_error(JSON::ParserError, /Expected '\{' or '\['/)
    end
  end
end
