System = java.lang.System
Thread = java.lang.Thread
Semaphore = java.util.concurrent.Semaphore
ScriptingContainer = Packages.org.jruby.embed.ScriptingContainer
LocalVariableBehavior = org.jruby.embed.LocalVariableBehavior
LocalContextScope = org.jruby.embed.LocalContextScope

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
        scriptingContainer.runScriptlet(code)

  ruby.setGemHome = (gemHome) ->
    ruby("ENV['GEM_HOME'] = #{gemHome}")

  return ruby

global.Ruby.preload = (gems...) ->
  unless runtimeState is RuntimeState.UNLOADED
    throw 'Ruby.preload([gems]) must be called exactly once'
  runtimeState = RuntimeState.LOADING
  (new Thread(() ->
    try
      scriptingContainer.runScriptlet makeRequireScript(gems...)
      runtimeState = RuntimeState.LOADED
    catch ex
      runtimeState = RuntimeState.FAILED
      throw ex
  )).start()

makeRequireScript = (gems...) ->
  if gems.length >= 1
    gems[1..gems.length].reduce(
      ((p, c) -> "#{p}; require '#{c}'"),
      "require '#{gems[0]}'"
    )
  else
    "nil"