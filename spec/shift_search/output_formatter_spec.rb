require "spec_helper"
require "json"
require "csv"
require "tempfile"

RSpec.describe ShiftSearch::OutputFormatter do
  let(:sample_data) do
    [
      { "name" => "John Doe", "email" => "john@example.com" },
      { "name" => "Jane Smith", "email" => "jane@example.com" }
    ]
  end

  describe ".output" do
    context "with JSON format" do
      it "formats data as pretty JSON when no output path is provided" do
        expect { described_class.output(sample_data, format: "json") }
          .to output(JSON.pretty_generate(sample_data) + "\n").to_stdout
      end

      it "saves formatted JSON to file when output path is provided" do
        Tempfile.create(["output", ".json"]) do |file|
          described_class.output(sample_data, format: "json", output_path: file.path)
          expect(File.read(file.path)).to eq(JSON.pretty_generate(sample_data))
        end
      end
    end

    context "with CSV format" do
      it "formats data as CSV when no output path is provided" do
        expected_csv = CSV.generate(headers: true) do |csv|
          csv << sample_data.first.keys
          sample_data.each { |row| csv << row.values }
        end

        expect { described_class.output(sample_data, format: "csv") }
          .to output(expected_csv + "\n").to_stdout
      end

      it "saves formatted CSV to file when output path is provided" do
        expected_csv = CSV.generate(headers: true) do |csv|
          csv << sample_data.first.keys
          sample_data.each { |row| csv << row.values }
        end

        Tempfile.create(["output", ".csv"]) do |file|
          described_class.output(sample_data, format: "csv", output_path: file.path)
          expect(File.read(file.path)).to eq(expected_csv)
        end
      end

      it "handles empty data" do
        expect { described_class.output([], format: "csv") }
          .to output("").to_stdout
      end
    end

    context "with invalid format" do
      it "raises error for unsupported format" do
        expect { described_class.output(sample_data, format: "xml") }
          .to raise_error(RuntimeError, "Unsupported format: xml")
      end
    end

    context "with file output" do
      it "prints success message when saving to file" do
        Tempfile.create(["output", ".json"]) do |file|
          expect { described_class.output(sample_data, format: "json", output_path: file.path) }
            .to output("Results saved to #{file.path}\n").to_stdout
        end
      end

      it "raises error when unable to write to file" do
        expect {
          described_class.output(sample_data, format: "json", output_path: "/nonexistent/path/file.json")
        }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe ".to_csv" do
    it "generates CSV with headers and data" do
      expected_csv = CSV.generate(headers: true) do |csv|
        csv << sample_data.first.keys
        sample_data.each { |row| csv << row.values }
      end

      expect(described_class.to_csv(sample_data)).to eq(expected_csv)
    end

    it "returns empty string for empty data" do
      expect(described_class.to_csv([])).to eq("")
    end

    it "handles single row of data" do
      single_row = [{ "name" => "John Doe", "email" => "john@example.com" }]
      expected_csv = CSV.generate(headers: true) do |csv|
        csv << single_row.first.keys
        csv << single_row.first.values
      end

      expect(described_class.to_csv(single_row)).to eq(expected_csv)
    end
  end
end
