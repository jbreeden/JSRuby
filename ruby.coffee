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