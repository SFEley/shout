module Shout
  module Listeners
    class Dummy
      attr_reader :foo

      def initialize(opts={})
        @foo = opts[:foo]
      end
    end
  end
end
