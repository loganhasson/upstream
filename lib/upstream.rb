require "upstream/version"

module Upstream

  class Tracker
    attr_reader :path, :pull

    def initialize(path, pull=false)
      @path = path
      @pull = pull
    end

    def self.run(path, pull)
      new(path, pull).setup
    end

    def setup
      wheneverizer = Wheneverizer.new(path, pull)
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
    attr_reader :path, :pull

    def initialize(path, pull=false)
      @path = path
      @already_existed = schedule_exists?
      @pull = pull
    end

    def run
      setup
      write_schedule
      wheneverize
      clean_up
    end

    def setup
      if !already_existed?
        if !File.exist?("#{path}/config")
          `cd #{path} && mkdir config && wheneverize .`
        else
          `cd #{path} && wheneverize .`
        end
      end
    end

    def schedule_exists?
      File.exist?("#{path}/config/schedule.rb")
    end

    def already_existed?
      @already_existed
    end

    def write_schedule
      if !schedule_exists?
        write_args = ['config/schedule.rb', 'w+']
      else
        write_args = ['config/schedule.rb', 'a']
      end

      fetch_or_pull = pull ? "pull" : "fetch"

      File.open(*write_args) do |f|
        f.puts <<-COMMAND.gsub(/^ {10}/, '')
          every 1.minute do
            command "eval $(ssh-agent) && ssh-add ~/.ssh/github_id_rsa && cd #{path} && git #{fetch_or_pull} upstream master"
          end
        COMMAND
      end
    end

    def wheneverize
      `whenever --update-crontab`
    end

    def clean_up
      file_count = `ls -a config | wc -l`.strip.to_i

      if !already_existed?
        if file_count > 3
          `rm config/schedule.rb`
        else
          `rm -rf config`
        end
      end
    end
  end

end
