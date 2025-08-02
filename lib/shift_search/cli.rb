require "optparse"

module ShiftSearch
  class CLI
    def run(args)
      options = { file: "data/clients.json" }

      OptionParser.new do |opts|
        opts.banner = "Usage: shift_search [options]"

        opts.on("-sQUERY", "--search=QUERY", "Search clients by name") do |query|
          options[:search] = query
        end

        opts.on("--duplicates", "Find duplicate emails") do
          options[:duplicates] = true
        end

        opts.on("-fFILE", "--file=FILE", "Path to JSON dataset") do |file|
          options[:file] = file
        end

        opts.on("-h", "--help", "Show help") do
          pp opts
          exit
        end
      end.parse!(args)

      data = ShiftSearch::DataLoader.load(options[:file])

      if options[:search]
        ShiftSearch::Search::Runner.new(data).run(options[:search])
      elsif options[:duplicates]
        ShiftSearch::Duplicates::Runner.new(data).run
      else
        pp "No command given. Use --help to see available options."
      end

      # TODO: implement output formatter (CSV, JSON, etc.)
    end
  end
end
