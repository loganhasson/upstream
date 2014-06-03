require "upstream/version"

module Upstream

  class Tracker
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def self.run(path)
      new(path).setup
    end

    def setup
      wheneverizer = Wheneverizer.new(path)
      wheneverizer.run
    end
  end

  class PathFinder
    attr_reader :raw_path

    def initialize(arg)
      @raw_path = arg
    end

    def self.get_path(arg)
      new(arg).parse
    end

    def parse
      if raw_path == '.'
        `pwd`.chomp
      else
        raw_path
      end
    end
  end

  class PathChecker
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def self.has_upstream?(path)
      new(path).check
    end

    def check
      `cd #{path} && git remote -v`.match(/upstream/) ? true : false
    end
  end

  class Wheneverizer
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def run
      setup
      write_schedule
      wheneverize
      clean_up
    end

    def setup
      `cd #{path} && wheneverize .`
    end

    def write_schedule
      File.open('config/schedule.rb', 'w+') do |f|
        f.write <<-COMMAND.stripheredoc.chomp
          every 1.minute do
            command "cd #{path} && git fetch upstream master"
          end
        COMMAND
      end
    end

    def wheneverize
      `whenever --update-crontab`
    end

    def clean_up
      file_count = `ls config -a | wc -l`.strip

      if file_count > 3
        `rm config/schedule.rb`
      else
        `rm -rf config`
      end
    end
  end

end
