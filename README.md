JSRuby
======

Run JRuby code from your Nashorn Projects

Synopsis
--------

```
C:\rubyjs> jrunscript -cp jars\jruby-complete-1.7.12.jar
nashorn> load('ruby.js')
nashorn> Ruby.preload()
nashorn> ruby = new Ruby()
nashorn> ruby('puts "Hello, World!"')
Hello, World!
```

Details
-------

Each `ruby` created by `new Ruby()` is a function that runs any code passed into it on a singleton
instance of [`ScriptingContainer`](http://jruby.org/apidocs/org/jruby/embed/ScriptingContainer.html) with
[concurrent local context scope](https://github.com/jruby/jruby/wiki/RedBridge#Concurrent).
This allows threads to share a single JRuby runtime, global variables, and top-level constants
(like any loaded classes) while keeping all other state, including local variables, thread-local.
This is illustrated by the CoffeeScript example below:

#### Example.coffee

```
load('ruby.js')
Thread = java.lang.Thread

Ruby.preload() # Required, and described below
ruby = new Ruby()

ruby """
  class K
    def initialize
      @var = 0
    end
    attr_accessor :var
  end

  $k = K.new

  k = K.new
"""

[1,2].forEach (i) ->
  ruby = new Ruby()
  (new Thread( ->
    ruby """
      puts "In #{i}: defined? K  == \#{defined? K}  \n"
      puts "In #{i}: defined? $k == \#{defined? $k} \n"
      puts "In #{i}: defined? k  == \#{defined? k}  \n"
      k = K.new
      k.var = #{i}
      puts "In #{i}: k.var set to #{i}\n"
    """
    Thread.sleep(50)
    ruby """
      puts "In #{i}: k.var == \#{k.var}  \n"
    """
  )).start()

java.lang.Thread.sleep 10000
```

#### Result

```
C:\projects\jsruby> jrunscript -cp jars\jruby-complete-1.7.12.jar thread-test.js
In 1: defined? K  == constant
In 2: defined? K  == constant
In 2: defined? $k == global-variable
In 1: defined? $k == global-variable
In 2: defined? k  ==
In 1: defined? k  ==
In 2: k.var set to 2
In 1: k.var set to 1
In 1: k.var == 1
In 2: k.var == 2
```

Notice that while the global variable `$k` and the class `K` are made available to all threads, the local
variables `k` created in each thread are visible only to that thread.

Another point of note is that CoffeeScript's syntax, with interpolated block strings, lends itself quite
well to embedding ruby code!

In addition to running ruby code, JSRuby provides some other conveniences, described below.

Preloading JRuby
----------------

JRuby has a notoriously slow startup time, most of which seems to be spent requiring gems.
This can be an issue if JRuby is in charge of your UI - say, if you're using [JRubyFX](https://github.com/jruby/jrubyfx).
However, with a UI written in JavaScript or CoffeeScript you can preload the JRuby runtime and
any gems you'll need while you're waiting on user input.

For this, JSRuby provides the `Ruby.preload` method. `Ruby.preload` must be called exactly once
before any ruby code invocation. Once called, `Ruby.preload` will `require` any and all of it's
arguments and initialize the JRuby runtime. This loading is done on a background thread so that
your application may remain responsive. Should any ruby code invocations occur before the runtime
has finished loading, they will simply sleep until the runtime load is complete.
Below, we see `preload` in action.

```
ruby = new Ruby()
ruby.preload 'sequel', 'net/ssh', 'nokogiri'

# Set up your UI...

myButton.onAction = ->
  # By now all of your gems are probably loaded,
  # otherwise the call to ruby will block until they are.
  ruby """
    DB = Sequel.connect('postgres://postgres@localhost:5432/postgres')
    # Let that Ruby shine!
  """
```

Setting Your GEM_HOME
---------------------

You can set your GEM_HOME by setting the environment variable in the usual ways,
or you may call `ruby.setGemHome('path/to/gems')`.

Requirements
------------

1. Java 8, complete with Nashorn
2. JRuby classes on the classpath
3. General enjoyment of luxury

Install
-------

Just copy the ruby.js file into your nashorn project, and `load('path/to/ruby.js')`

LICENSE
-------

(The MIT License)

Copyright (c) 2014 Jared Breeden

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
