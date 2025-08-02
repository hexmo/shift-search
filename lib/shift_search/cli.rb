require "optparse"

module ShiftSearch
  class CLI
    def run(args)
      options = { file: "data/clients.json", key: "full_name", format: "json" }

      OptionParser.new do |opts|
        opts.banner = "Usage: shift_search [options]"

        opts.on("-sQUERY", "--search=QUERY", "Search clients by name") do |query|
          options[:search] = query
        end

        opts.on("-kKEY", "--key=KEY", "Field to search (default: #{options[:key]})") do |key|
          options[:key] = key
        end

        opts.on("--duplicates", "Find duplicate emails") do
          options[:duplicates] = true
        end

        opts.on("-fFILE", "--file=FILE", "Path to JSON dataset (default: #{options[:file]})") do |file|
          options[:file] = file
        end

        opts.on("--format=FORMAT", "Output format: json or csv (default: json)") do |format|
          options[:format] = format
        end

        opts.on("-oFILE", "--output=FILE", "Output file path (optional)") do |output|
          options[:output] = output
        end

        opts.on("-h", "--help", "Show help") do
          puts opts
          exit
        end
      end.parse!(args)

      begin
        data = ShiftSearch::DataLoader.load(options[:file])
      rescue => e
        puts "Error loading data: #{e.message}"
        return
      end

      if options[:search]
        ShiftSearch::Search::Runner.new(data).run(
          options[:search],
          options[:key],
          options[:format],
          output: options[:output]
        )
      elsif options[:duplicates]
        ShiftSearch::Duplicates::Runner.new(data).run(
          options[:format],
          output: options[:output]
        )
      else
        puts "No command given. Use --help to see available options."
      end
    end
  end
end
