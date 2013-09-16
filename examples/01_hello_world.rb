require 'bundler/setup'
require 'shout'

# Built-in listener that outputs in logfile format
Shout.listener :text, :to => STDOUT

class Greeter
  include Shout

  def greet
    shout 'Hello, world!'
  end
end

g = Greeter.new
g.greet
