module ActsAsFu
  class Connection < ActiveRecord::Base
    cattr_accessor :connected
    cattr_reader :log
    self.abstract_class = true

    def self.connect!(config={})
      @@log       = ""
      self.logger = Logger.new(StringIO.new(log))
      self.establish_connection(config)
    end
  end
end