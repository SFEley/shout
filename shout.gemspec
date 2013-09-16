# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "shout"
  spec.version       = File.read(File.join(File.dirname(__FILE__), 'shout.version')).chomp
  spec.authors       = ["Stephen Eley"]
  spec.email         = ["sfeley@gmail.com"]
  spec.description   = %q{Shout listens for things happening in your Ruby application and tells other parts of your world about them. It's built on [ZeroMQ][0mq] for lightweight speed and reliability, and handles event logging and service monitoring with minimal changes to your application code. Events can be caught and processed within the same application, by a central service on the same machine, or by distributed services across the network. It's a publish/subscribe flow with simple configure-it-once routing.}
  spec.summary       = "A simple ZeroMQ-based distributed logging and event framework"
  spec.homepage      = "http://github.com/SFEley/shout"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
