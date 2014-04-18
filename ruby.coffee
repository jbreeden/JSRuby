System = java.lang.System
Thread = java.lang.Thread
Semaphore = java.util.concurrent.Semaphore
ScriptingContainer = Packages.org.jruby.embed.ScriptingContainer
LocalVariableBehavior = org.jruby.embed.LocalVariableBehavior;

@Ruby = ->
  rubyMutex = new Semaphore(1)
  scriptingContainer = new ScriptingContainer(
    LocalVariableBehavior.PERSISTENT
  )

  ruby = (code) ->
    rubyMutex.acquire()
    result = scriptingContainer.runScriptlet(code)
    rubyMutex.release()
    return result

  ruby.setGemHome = (gemHome) ->
    ruby("ENV['GEM_HOME'] = #{gemHome}")

  ruby.preload = (list) ->
    if list?.length?
      script = list[1..list.length].reduce(
        ((p, c) -> "#{p}; require '#{c}'"),
        "require '#{list[0]}'"
      )
    else if list?
      script = "require #{list}"
    else
      script = ""
    requireThread = new Thread(() ->
      rubyMutex.acquire()
      scriptingContainer.runScriptlet script
      rubyMutex.release()
    )
    requireThread.start()

  return ruby