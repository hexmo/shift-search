require "spec_helper"

RSpec.describe ShiftSearch::Duplicates::Runner do
  describe "#run" do
    context "when duplicates exist" do
      let(:data_with_duplicates) do
        [
          { "full_name" => "John Doe", "email" => "same@example.com" },
          { "full_name" => "Jane Smith", "email" => "unique@example.com" },
          { "full_name" => "John Smith", "email" => "same@example.com" },
          { "full_name" => "Alice Brown", "email" => "another_dupe@example.com" },
          { "full_name" => "Bob Brown", "email" => "another_dupe@example.com" }
        ]
      end

      subject(:runner) { described_class.new(data_with_duplicates) }

      it "identifies and formats duplicate entries in JSON" do
        expected_output = [
          data_with_duplicates[0].merge("duplicate_email" => "same@example.com"),
          data_with_duplicates[2].merge("duplicate_email" => "same@example.com"),
          data_with_duplicates[3].merge("duplicate_email" => "another_dupe@example.com"),
          data_with_duplicates[4].merge("duplicate_email" => "another_dupe@example.com")
        ]

        expect { runner.run("json") }
          .to output(JSON.pretty_generate(expected_output) + "\n").to_stdout
      end

      it "outputs duplicates in CSV format" do
        duplicate_records = [
          data_with_duplicates[0].merge("duplicate_email" => "same@example.com"),
          data_with_duplicates[2].merge("duplicate_email" => "same@example.com"),
          data_with_duplicates[3].merge("duplicate_email" => "another_dupe@example.com"),
          data_with_duplicates[4].merge("duplicate_email" => "another_dupe@example.com")
        ]

        expected_csv = CSV.generate(headers: true) do |csv|
          csv << duplicate_records.first.keys
          duplicate_records.each { |record| csv << record.values }
        end

        expect { runner.run("csv") }
          .to output(expected_csv + "\n").to_stdout
      end

      it "saves duplicates to file when output path is provided" do
        Tempfile.create(["duplicates", ".json"]) do |file|
          expect { runner.run("json", output: file.path) }
            .to output("Results saved to #{file.path}\n").to_stdout

          saved_data = JSON.parse(File.read(file.path))
          expect(saved_data.size).to eq(4)
          expect(saved_data.map { |r| r["duplicate_email"] }.uniq.sort)
            .to eq(["another_dupe@example.com", "same@example.com"])
        end
      end

      it "adds duplicate_email field to each duplicate record" do
        output = nil
        expect { output = capture_stdout { runner.run("json") } }.not_to raise_error
        
        parsed_output = JSON.parse(output.strip)  # Strip trailing newline
        expect(parsed_output).to all(include("duplicate_email"))
        
        # Each record should have its duplicate_email match its original email
        parsed_output.each do |record|
          expect(record["duplicate_email"]).to eq(record["email"])
        end
      end
    end

    context "when no duplicates exist" do
      let(:unique_data) do
        [
          { "full_name" => "John Doe", "email" => "john@example.com" },
          { "full_name" => "Jane Smith", "email" => "jane@example.com" },
          { "full_name" => "Bob Brown", "email" => "bob@example.com" }
        ]
      end

      subject(:runner) { described_class.new(unique_data) }

      it "outputs appropriate message when no duplicates found" do
        expect { runner.run("json") }
          .to output("No duplicate emails found.\n").to_stdout
      end
    end

    context "with edge cases" do
      it "handles empty dataset" do
        runner = described_class.new([])
        expect { runner.run("json") }
          .to output("No duplicate emails found.\n").to_stdout
      end

      it "identifies case-insensitive email duplicates" do
        data = [
          { "full_name" => "John Doe", "email" => "TEST@example.com" },
          { "full_name" => "Jane Doe", "email" => "test@example.com" }
        ]
        expected_output = [
          data[0].merge("duplicate_email" => "TEST@example.com"),
          data[1].merge("duplicate_email" => "test@example.com")
        ]
        
        runner = described_class.new(data)
        expect { runner.run("json") }
          .to output(JSON.pretty_generate(expected_output) + "\n").to_stdout
      end

      it "handles records with missing email field" do
        data = [
          { "full_name" => "John Doe" },
          { "full_name" => "Jane Smith", "email" => nil },
          { "full_name" => "Bob Brown", "email" => "" }
        ]
        runner = described_class.new(data)
        expect { runner.run("json") }
          .to output("No duplicate emails found.\n").to_stdout
      end
    end
  end
end
