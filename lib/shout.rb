require 'shout/class_methods'  # Attributes and macros for class extension

module Shout
  class << self
    attr_writer :service

    # High-level category for generated events. Defaults to the name of the calling program.
    def service
      @service ||= File.basename($PROGRAM_NAME.to_s)
    end

  end

protected
  attr_writer :shouter

  # Returns the Shouter (event emitter) for the object, which is the one
  # shared by the entire class if you don't override it.
  def shouter
    @shouter || self.class.shouter
  end

  def shout(*args)
    shouter.shout *args
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

end
