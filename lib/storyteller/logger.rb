require 'logger'

module Storyteller
  class CustomLogger < Logger
    def initialize
      super($stdout)
      self.level = Logger::INFO
      self.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime}: [#{severity}] #{progname} - #{msg}\n"
      end
    end
  end
end
