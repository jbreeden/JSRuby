// Generated by CoffeeScript 1.7.1
(function() {
  var Thread, ruby;

  load('ruby.js');

  Thread = java.lang.Thread;

  Ruby.preload();

  ruby = new Ruby();

  ruby("class K\n  def initialize\n    @var = 0\n  end\n  attr_accessor :var\nend\n\n$k = K.new\n\nk = K.new");

  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].forEach(function(i) {
    ruby = new Ruby();
    return (new Thread(function() {
      ruby("puts \"In " + i + ": defined? K  == \#{defined? K}  \n\"\nputs \"In " + i + ": defined? $k == \#{defined? $k} \n\"\nputs \"In " + i + ": defined? k  == \#{defined? k}  \n\"\nk = K.new\nk.var = " + i + "\nputs \"In " + i + ": k.var set to " + i + "\n\"");
      Thread.sleep(50);
      return ruby("puts \"In " + i + ": k.var == \#{k.var}  \n\"");
    })).start();
  });

  java.lang.Thread.sleep(10000);

}).call(this);
