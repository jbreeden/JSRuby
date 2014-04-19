load('ruby.js')
Thread = java.lang.Thread

#Ruby.preload()

################################
# Basic test: Multiple Rubies  #
################################

#[1..20].forEach (i) ->
#  ruby = new Ruby()
#  (new Thread(->
#    ruby('puts("Hello from ruby #' + i + '\n")')
#  )).start()
#
#java.lang.Thread.sleep 60000

##################################
# Test: Class Instance Variables #
##################################

#ruby = new Ruby()
#
#ruby """
#  class K
#    @var = 0
#    def self.var
#      @var
#    end
#    def self.var=(val)
#      @var = val
#    end
#  end
#"""
#
#[1..20].forEach (i) ->
#  ruby = new Ruby()
#  (new Thread( ->
#    ruby """
#      puts "In #{i}, setting K.var\n"
#      K.var = #{i}
#    """
#    Thread.sleep(50)
#    ruby('puts "In ' + i + ' K.var = #{K.var}\n"')
#  )).start()
#
#java.lang.Thread.sleep 60000

############################
# Test: Instance Variables #
############################

Ruby.preload()
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

[1..10].forEach (i) ->
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