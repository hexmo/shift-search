require "spec_helper"

RSpec.describe ShiftSearch::CLI do
  let(:cli) { described_class.new }
  let(:default_file) { "data/clients.json" }
  let(:alternate_file) { "data/clients2.json" }
  let(:empty_file) { "data/empty.json" }

  describe "#run" do
    context "with search option" do
      it "executes search with default options" do
        output = capture_stdout do
          cli.run(["-s", "John Doe"])
        end
        expect(output).to include("john.doe@gmail.com")
      end

      it "respects custom key option" do
        output = capture_stdout do
          cli.run(["-s", "john.doe@gmail.com", "-k", "email"])
        end
        expect(output).to include("John Doe")
      end

      it "handles search in alternate file with different field names" do
        output = capture_stdout do
          cli.run(["-s", "John Doe", "-f", alternate_file, "-k", "legal_name"])
        end
        expect(output).to include("john.doe@gmail.com")
      end

      it "returns empty results for non-existent search term" do
        output = capture_stdout do
          cli.run(["-s", "NonExistentPerson"])
        end
        expect(output).to include("No matches found for 'NonExistentPerson' in 'full_name'")
      end
    end

    context "with duplicates option" do
      it "finds duplicate emails in the default dataset" do
        output = capture_stdout do
          cli.run(["--duplicates"])
        end
        expect(output).to include('"email": "jane.smith@yahoo.com"')
        expect(output).to include('"duplicate_email": "jane.smith@yahoo.com"')
      end

      it "finds duplicate emails in combined datasets" do
        output = capture_stdout do
          cli.run(["--duplicates", "-f", "#{default_file},#{alternate_file}"])
        end
        expect(output).to include("john.doe@gmail.com")
        expect(output).to include("jane.smith@yahoo.com")
      end
    end

    context "with custom file option" do
      it "loads and searches in empty file" do
        output = capture_stdout do
          cli.run(["-s", "John", "-f", empty_file])
        end
        expect(output).to include("[]")
      end

      it "loads and searches in alternate file" do
        output = capture_stdout do
          cli.run(["-s", "John", "-f", alternate_file])
        end
        expect(output).to include("john.doe@gmail.com")
      end
    end

    context "with help option" do
      it "displays help message and exits" do
        output = capture_stdout do
          expect { cli.run(["-h"]) }.to raise_error(SystemExit)
        end

        expect(output).to include("Usage: shift_search [options]")
      end
    end

    context "with output format option" do
      it "outputs in JSON format by default" do
        output = capture_stdout do
          cli.run(["-s", "John Doe"])
        end
        expect(output).to include('"full_name"')
        expect(output).to include('"email"')
      end

      it "outputs in CSV format when specified" do
        output = capture_stdout do
          cli.run(["-s", "John Doe", "--format=csv"])
        end
        expect(output).to include("full_name,email")
        expect(output).to include("John Doe,john.doe@gmail.com")
      end
    end

    context "with invalid file" do
      it "handles non-existent file gracefully" do
        output = capture_stdout do
          expect { cli.run(["-s", "John", "-f", "nonexistent.json"]) }.to raise_error(SystemExit)
        end
        expect(output).to include("Error loading data")
      end

      it "handles malformed JSON file gracefully" do
        output = capture_stdout do
          expect { cli.run(["-s", "John", "-f", "data/image.png"]) }.to raise_error(SystemExit)
        end
        expect(output).to include("Error loading data")
      end

      it "handles search with image file as input gracefully" do
        output = capture_stdout do
          expect { cli.run(["-s", "image data", "-f", "data/image.png"]) }.to raise_error(SystemExit)
        end
        expect(output).to include("Error loading data")
        expect(output).not_to include("image data") # Ensure no partial matches from binary data
      end
    end
  end
end
