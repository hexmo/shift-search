require "spec_helper"

RSpec.describe ShiftSearch::Search::Runner do
  let(:sample_data) do
    [
      { "full_name" => "John Doe", "email" => "john@example.com", "phone" => "123-456-7890" },
      { "full_name" => "Jane Smith", "email" => "jane@example.com", "phone" => "098-765-4321" },
      { "full_name" => "John Smith", "email" => "johns@example.com", "phone" => "111-222-3333" }
    ]
  end

  subject(:runner) { described_class.new(sample_data) }

  describe "#run" do
    context "with valid search parameters" do
      it "finds matches by exact value" do
        expect { runner.run("John Doe", "full_name", "json") }
          .to output(JSON.pretty_generate([sample_data[0]]) + "\n").to_stdout
      end

      it "finds matches case-insensitively" do
        expect { runner.run("john", "full_name", "json") }
          .to output(JSON.pretty_generate([sample_data[0], sample_data[2]]) + "\n").to_stdout
      end

      it "finds partial matches" do
        expect { runner.run("Smith", "full_name", "json") }
          .to output(JSON.pretty_generate([sample_data[1], sample_data[2]]) + "\n").to_stdout
      end

      it "handles no matches gracefully" do
        expect { runner.run("NotFound", "full_name", "json") }
          .to output("No matches found for 'NotFound' in 'full_name'\n").to_stdout
      end

      it "searches in email field" do
        expect { runner.run("jane", "email", "json") }
          .to output(JSON.pretty_generate([sample_data[1]]) + "\n").to_stdout
      end

      it "outputs in CSV format" do
        expected_csv = CSV.generate(headers: true) do |csv|
          csv << sample_data.first.keys
          csv << sample_data[0].values
        end
        expect { runner.run("John Doe", "full_name", "csv") }
          .to output(expected_csv + "\n").to_stdout
      end

      it "saves output to file when output path is provided" do
        Tempfile.create(["search_results", ".json"]) do |file|
          expect { runner.run("John", "full_name", "json", output: file.path) }
            .to output("Results saved to #{file.path}\n").to_stdout
          
          saved_data = JSON.parse(File.read(file.path))
          expect(saved_data).to contain_exactly(sample_data[0], sample_data[2])
        end
      end
    end

    context "with edge cases" do
      it "handles empty data set" do
        empty_runner = described_class.new([])
        expect { empty_runner.run("any", "key", "json") }
          .to output("No client data to search.\n").to_stdout
      end

      it "handles invalid key" do
        expect { runner.run("any", "invalid_key", "json") }
          .to output([
            "The field 'invalid_key' is not present in the client records.",
            "Available fields: full_name, email, phone",
            ""
          ].join("\n")).to_stdout
      end

      it "converts non-string values to strings for comparison" do
        data_with_numbers = [{ "id" => 123, "name" => "Test" }]
        number_runner = described_class.new(data_with_numbers)
        expect { number_runner.run("123", "id", "json") }
          .to output(JSON.pretty_generate([data_with_numbers[0]]) + "\n").to_stdout
      end
    end

    context "with special characters" do
      let(:special_data) do
        [
          { "name" => "Test (special)", "email" => "test+special@example.com" },
          { "name" => "Test [bracket]", "email" => "test@example.com" }
        ]
      end
      let(:special_runner) { described_class.new(special_data) }

      it "handles parentheses in search terms" do
        expect { special_runner.run("(special)", "name", "json") }
          .to output(JSON.pretty_generate([special_data[0]]) + "\n").to_stdout
      end

      it "handles special characters in email addresses" do
        expect { special_runner.run("test+special", "email", "json") }
          .to output(JSON.pretty_generate([special_data[0]]) + "\n").to_stdout
      end

      it "handles brackets in search terms" do
        expect { special_runner.run("[bracket]", "name", "json") }
          .to output(JSON.pretty_generate([special_data[1]]) + "\n").to_stdout
      end
    end
  end
end
