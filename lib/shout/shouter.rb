require 'shout'

module Shout

  # Generates and sends events out for the benefit of listeners. The
  # `shout` method is the meat here; everything else is configuration.
  class Shouter
    attr_accessor :service, :component

    # @option opts [String] :service Event category. Defaults to the application name from the command line.
    # @option opts [String] :component Event subcategory. Defaults to the class name if auto-created from a module inclusion; else an empty string.
    def initialize(opts={})
      @service = opts.fetch :service, Shout.service
      @component = opts.fetch :component, ''
    end
  end
end
