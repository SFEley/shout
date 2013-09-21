require 'shout/shouter'

module Shout
  module ClassMethods
    attr_writer :shouter

    # Returns the current shouter for the class, or initializes a new one
    # with the class's name as its component name.
    def shouter
      @shouter ||= Shouter.new :component => self.name
    end

  end
end
