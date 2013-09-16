shout
=====

Shout listens for things happening in your Ruby application and tells other parts of your world about them. It's built on [ZeroMQ][0mq] for lightweight speed and reliability, and handles event logging and service monitoring with minimal changes to your application code. Events can be caught and processed within the same application, by a central service on the same machine, or by distributed services across the network. It's a publish/subscribe flow with simple configure-it-once routing.

Shout comes with the following out of the box:

* a top-level module with a simple `shout` method you can use anywhere you like;
* an event logging class that acts as a drop-in replacement for the standard Logger;
* class macros that can shout every time a particular method begins or ends, with or without parameters or profiling;
* a skeleton framework for pluggable listeners;
* an example listener that writes events to a text file (completing the Logger replacement);
* a network discovery service that connects shouters and listeners;
* an optional server daemon that can consolidate shouts, discovery, and listeners as needed.

A number of useful shouters and listeners are provided in separate gems. All of them can be run within an application or from the **shout** executable.

## Getting Started
The simplest configuration is a single shouter with a single listener in the same process. Include `gem 'shout'` in your Gemfile, intone the customary `bundle install` from the command line, and then greet the world:

```ruby
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
```
 
If you saved that snippet to a file named **hello.rb** and ran it, you would see something like the following: 

    2013-09-15 18:31:45 (hello/Greeter) INFO : Hello, world!
    
By itself this isn't very fascinating (there are easier ways to write to standard output) but when you consider what the code is doing behind the scenes, you may start to realize just how flexible this is:

1. The `require 'shout'` sets up the namespace and a smallish module for basic configuration and event sending.  Listeners and routers are not loaded until they are asked for.

1. The `Shout.listener :text` method call:

  1. Requires shout/listeners/text.rb and creates a new **Shout::Listeners::Text** object with the given parameters.  *The following steps are performed by the Text listener.*

  1. Spawns off a thread and creates a couple of ZeroMQ sockets within it for finding out about shouters and events.

  1. Connects those sockets to a *hub* and asks it for any current shouters to listen to.  We haven't configured a hub, so an internal (app-only) one is automatically created behind the scenes.

  1. There are no shouters yet except the hub itself, so the listener subscribes to the hub and waits for an event to happen. 

1. Putting `include Shout` in the Greeter class:

  1. Adds a *class attribute* called `shouter` which lazily (on first access) creates a **Shout::Shouter** object. This object defaults the service and component names to the program and class name, but you could override them or pass in a completely different shouter object.

  1. Adds a *protected attribute* called `shouter` which delegates to the class attribute. The intent is that every object of the class shares one shouter (and thus one ZeroMQ socket) by default, but you can create or point to different ones if you want to.

  1. Adds a *protected method* called `shout` which delegates to the shouter.  (*Why protected?* So we don't taint any of your public APIs, while still allowing you to write `self.shout` or set related objects' shouters. You can always make them public yourself if there's a need for it.)

1. Finally, calling the `shout` method:

  1. Causes the class's **Shouter** object to spring into existence, since this was the first time we asked for it.  (This would also create the internal *hub* if we hadn't already done it for the listener.) *The following steps are performed by the shouter.* 
  
  1. Creates a ZeroMQ socket and connects it to the hub.
  
  1. Announces its own existence to the hub, including its service and component names (i.e., application and class). The hub forwards the news to all listeners, and adds the shouter to a registry for any future listeners.
  
  1. Having initialized everything, pushes the "Hello, world!" message to the hub as an INFO event (the default). The hub publishes the event to all listeners.
  
1. The Text listener, sitting quietly in its own thread waiting for something to do, receives the event and does what its `receive` method tells it to do, which is to format the event's properties and write them to the given destination (standard output in this case).


## Events
Shout's atomic unit is an *event*, which is an object delivered as a structured text message. Every events has _at least_ the following fields, and may have more depending on your needs:

* **type** - The event's purpose and urgency. This is a hardcoded list; see *event types* below.
* **service** - A high-level category name which can be used as a filter by listeners. Defaults to the application name as inferred from the command line. Cannot be blank.
* **component** - A lower-level subcategory name which can be used as a more specific filter. Defaults to the class name in which the **Shout** module was included, but may be overridden or set to blank.
* **host** - The server from which the event originated. Defaults to the operating system's hostname, but can be overridden.
* **pid** - The process from which the event originated. Defaults to the operating system process ID, but can be overridden if some other identifier makes sense for your deployment.
* **time** - The timestamp of the event's creation, accurate to within milliseconds. Cannot be overridden.
* **version** - The API version of the Shout code that created the event. (*Not* the same as the gem version.)
* **message** - A human-readable text string describing the event. Always exists, but may be blank.
* *other fields* - Anything else you provide as a parameter to the `shout` method or its derivatives will be serialized as YAML and made available to listeners as fields on the event object.

### Event Types
Shout makes it possible to listeners to filter on the type and/or the service. However, because ZeroMQ's filtering is strictly based on prefixes, it is necessary for one or both of those fields to be a fixed (and short!) list.

Shout's original use case is logging, and the classic [severity levels][severity] used by the Ruby Logger class turn out to be useful for many other purposes as well. Shout's types are therefore a superset of these logging levels:

* **:meta** - Used by Shout itself to inform listeners when a shouter appears or disappears and for heartbeats. Cannot be sent by user code. Usually invisible, but can be caught and acted upon in user code by filtering for it specifically.
* **:fatal** - Sent by Shout when an application exits abnormally. Can also be sent from user code. Generally indicates a complete failure or a true emergency condition.
* **:error** - Sent by user code, usually from exception handlers. Indicates that a process or task has failed and intervention or investigation is needed.
* **:warn** - Sent by user code. Indicates an unusual condition that was handled successfully or which calls for eventual (non-critical) investigation.
* **:info** - Sent by user code. Signals normal operations that may be of interest for statistics or for followup actions.
* **:debug** - Sent by user code. Interesting only for developers and often filtered out by listeners.

The following *type groups* are also recognized when setting up a listener:

* **:common** - Includes the **:fatal**, **:error**, **:warn** and **:info** types. *This is the default filter for listeners.*
* **:problems** - Includes the **:fatal**, **:error** and **:warn** types.
* **:all** - Includes all user-facing types: **:fatal**, **:error**, **:warn**, **:info** and **:debug**. Does *not* include the **:meta** type.

Creating new event types and informing listeners about them is a feature that may happen in the future if there's enough interest. 



[0mq]:http://zeromq.org
[severity]:http://www.ruby-doc.org/stdlib-2.0.0/libdoc/logger/rdoc/Logger/Severity.html

