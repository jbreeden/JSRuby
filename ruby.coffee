System = java.lang.System
Thread = java.lang.Thread
Semaphore = java.util.concurrent.Semaphore
ScriptingContainer = Packages.org.jruby.embed.ScriptingContainer
LocalVariableBehavior = org.jruby.embed.LocalVariableBehavior
LocalContextScope = org.jruby.embed.LocalContextScope

#  LocalContextScope.SINGLETON:
#
#  +------------------------------------------------------------+
#  |                       Variable Map                         |
#  +------------------------------------------------------------+
#  +------------------------------------------------------------+
#  |                       Ruby runtime                         |
#  +------------------------------------------------------------+
#  +------------------+ +------------------+ +------------------+
#  |ScriptingContainer| |ScriptingContainer| |ScriptingContainer|
#  +------------------+ +------------------+ +------------------+
#  +------------------------------------------------------------+
#  |                         JVM                                |
#  +------------------------------------------------------------+

#@Ruby = ->
#  scriptingContainer = new ScriptingContainer(
#    LocalContextScope.SINGLETON,
#    LocalVariableBehavior.PERSISTENT
#  )
#
#  ruby = (code) ->
#    @Ruby.GIL.acquire()
#    result = scriptingContainer.runScriptlet(code)
#    @Ruby.GIL.release()
#    return result
#
#  ruby.setGemHome = (gemHome) ->
#    ruby("ENV['GEM_HOME'] = #{gemHome}")
#
#  ruby.preload = (gems...) ->
#    if gems.length >= 1
#      script = gems[1..gems.length].reduce(
#        ((p, c) -> "#{p}; require '#{c}'"),
#        "require '#{gems[0]}'"
#      )
#    else
#      script = "nil"
#
#    requireThread = new Thread(() ->
#      @Ruby.GIL.acquire()
#      scriptingContainer.runScriptlet script
#      @Ruby.GIL.release()
#    )
#    requireThread.start()
#
#  return ruby
#
#@Ruby.GIL = new Semaphore


####################################
## READ/WRITE LOCK IMPLEMENTATION
####################################
#
#global = this;
#
#ReentrantReadWriteLock = java.util.concurrent.locks.ReentrantReadWriteLock
#
#readWriteLock = new ReentrantReadWriteLock(true);
#readLock = readWriteLock.readLock();
#writeLock = readWriteLock.writeLock();
#
#scriptingContainer = new ScriptingContainer(
#  LocalContextScope.CONCURRENT,
#  LocalVariableBehavior.PERSISTENT
#)
#
#RuntimeState = {
#  UNLOADED: 0
#  LOADED: 1
#  FAILED: 2
#}
#
#runtimeState = RuntimeState.UNLOADED
#
#global.Ruby = ->
#  ruby = (code) ->
#    switch runtimeState
#      when RuntimeState.UNLOADED
#        while runtimeState == RuntimeState.UNLOADED
#          System.out.println "Waiting on runtime load #{Thread.currentThread()}"
#          Thread.sleep(100)
#        ruby(code)
#      when RuntimeState.FAILED
#        throw 'Ruby runtime failed to load.'
#      when RuntimeState.LOADED
#        System.out.println "Executing ruby code"
#        readLock.lock()
#        try
#          System.out.println "READ LOCK: Got"
#          result = scriptingContainer.runScriptlet(code)
#        finally
#          System.out.println "READ LOCK: Releasing"
#          readLock.unlock()
#        return result
#
#  ruby.setGemHome = (gemHome) ->
#    ruby("ENV['GEM_HOME'] = #{gemHome}")
#
#  return ruby
#
#global.Ruby.init = (gems...) ->
#  if gems.length >= 1
#    script = gems[1..gems.length].reduce(
#      ((p, c) -> "#{p}; require '#{c}'"),
#      "require '#{gems[0]}'"
#    )
#  else
#    script = "nil"
#
#  (new Thread(() ->
#    writeLock.lock()
#    try
#      System.out.println "WRITE LOCK: Got"
#      return if runtimeState == RuntimeState.LOADED
#      scriptingContainer.runScriptlet script
#      runtimeState = RuntimeState.LOADED
#    catch ex
#      runtimeState = RuntimeState.FAILED
#      throw ex
#    finally
#      System.out.println "WRITE LOCK: Releasing"
#      writeLock.unlock()
#  )).start()

###################################
# Flag IMPLEMENTATION
###################################

global = this;

scriptingContainer = new ScriptingContainer(
  LocalContextScope.CONCURRENT,
  LocalVariableBehavior.PERSISTENT
)

RuntimeState = {
  UNLOADED: 0
  LOADING: 1
  LOADED: 2
  FAILED: 3
}

runtimeState = RuntimeState.UNLOADED

global.Ruby = ->
  ruby = (code) ->
    switch runtimeState
      when RuntimeState.UNLOADED
        throw 'Must call Ruby.preload([gems]) exactly once before executing ruby code'
      when RuntimeState.LOADING
        while runtimeState == RuntimeState.LOADING
          Thread.sleep(100)
        ruby(code)
      when RuntimeState.FAILED
        throw 'Ruby runtime failed to load.'
      when RuntimeState.LOADED
        result = scriptingContainer.runScriptlet(code)
        return result

  ruby.setGemHome = (gemHome) ->
    ruby("ENV['GEM_HOME'] = #{gemHome}")

  return ruby

global.Ruby.preload = (gems...) ->
  runtimeState = RuntimeState.LOADING

  if gems.length >= 1
    script = gems[1..gems.length].reduce(
      ((p, c) -> "#{p}; require '#{c}'"),
      "require '#{gems[0]}'"
    )
  else
    script = "nil"

  (new Thread(() ->
    try
      return if runtimeState == RuntimeState.LOADED
      scriptingContainer.runScriptlet script
      runtimeState = RuntimeState.LOADED
    catch ex
      runtimeState = RuntimeState.FAILED
      throw ex
  )).start()