JSRUBY
======

Run JRuby code from your Nashorn Projects

Synopsis
--------

```
C:\rubyjs>jrunscript -cp jars\jruby-complete-1.7.12.jar
nashorn> load('ruby.js')
nashorn> ruby = new Ruby()
nashorn> ruby('puts "Hello, World!"')
Hello, World!
```

Details
-------

Each `ruby` created by `new Ruby()` wraps an instance of `org.jruby.embed.ScriptingContainer`.
In addition to running any ruby code passed into the `ruby` as a string, JSRuby provides some
other conveniences, described below.

Preloading JRuby
----------------

JRuby has a notoriously slow startup time, most of which seems to be spent requiring gems.
This can be an issue if JRuby is in charge of your UI - say, if you're using JRubyFX.
However, with a UI written in JavaScript or CoffeeScript you can preload JRuby the runtime and
any gems you'll need while you're waiting on user input.

For this, JSRuby provides the `preload` method on all `Ruby` objects. `preload` will `require`
all of it's arguments (if any) and initialize the JRuby runtime. Below, we can see `preload` being
used from CoffeeScript.

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
