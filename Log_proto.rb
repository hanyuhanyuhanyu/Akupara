=begin
Log collector class の機能
・Log classがnewされる度に、Log collectorクラスを通じてそれの通知を受ける
・Log collector クラスがnewされる度に、集積先のLog collectorインスタンスを最新のインスタンスに切り替える。
・この切り替えを任意に行えるようにする
・つーか集積先のLog collectorの名前を各Log classに教えておくことにする。Log collectorがクラス単位で管理するのは、Log newされるときに教えられるLog collectorの名前だけである。
・この切り替えは基本的に任意に行えない。恣意的に切り替えを行いたい場合は、switch_to_meメソッドを使ったうえで、ブロック内でその他のインスタンスの作成を行う必要がある。これ以外の方法でインスタンスの生成を行った場合は、最も新しいログcollectorにLogインスタンスは参照されてしまう
・集積されたLog classを番号順に並べてLogを作成する
Log classの機能
・ログを取る。ログを取るたび、すべてのLog classインスタンスで共有されている番号を1addしたうえで、addされる前の数値を自分の番号として持つ
=end
=begin
Logシステムの概要
Logシステムを構成するクラスの包含関係は次の通り。
Logger＞Log＞Single_Log
Loggerはnewする度にクラス変数@@serialを1addすることで一意性を確保している。
Logは、Logger.start_logging method内で各オブジェクト内のインスタンス変数として生成されるとともに、Loggerインスタンスによって参照される。
これによって、Logすべきであるものを指定することが可能になる。
すべてのオブジェクトは、@logというインスタンス変数を持ち、ここにLog classインスタンスを保持する。
そのオブジェクトが何かしらのメソッドを実行した時、そのメソッドを実行するとともに、Logに実行情報を差し渡すこの機能は未実装である。
この、Logを差し渡す作業を行うには、Log インスタンスのlog method を呼べば良い。
log method を呼ぶと、Log インスタンスは、Single_log インスタンスをnewしようとする。
Single_log は、その名の通り、たった一つのLog情報を持つものである。Single_logクラスがnewされる度、所属するLoggerごとのサロゲートキーが1addされることで、各Single_logは時系列順に自分のIDを保持することが可能となる。
Loggerクラスのdump_log methodを実行することで、そのLoggerクラスに参照されているLogの全てのLogが吐き出される。
=end
class BaseObject
  def logging(logger_sym)
    @log = Log.new logger_sym
    self
  end
  def dump_log
    @log.dump
  end
end
class Logger
  attr_reader :to_sym
  @@serial = 0
  def self.assign(logger)
  end
  def initialize
    @to_sym = "log".+(@@serial.to_s).to_sym
    @@serial += 1
    @logs = []
  end
  def start_logging(*logged_objs)
    logged_objs.each{|obj|@logs << obj.logging(@to_sym)}
  end
  def dump_log
    @logs.flatten.map(&:dump_log).flatten.sort_by(&:num).map(&:to_log).join("\n")
  end
end
class Log
  #各Logger クラスの名前に対応した番号を保持する。
  @@log_num = {}
  attr_reader :logger
  def initialize(logger_name)
    @logger = logger_name
    @logs = []
  end
  def log(receiver,method,*args)
    log_num = @@log_num[@logger] || 0
    @@log_num[@logger] = log_num + 1
    #メソッド名と、レシーバ、引数をそのまま渡す。to_symとかするかどうかは受け取り側に任せる
    @logs <<  Single_log.new(log_num,reveiver,method,*args)
  end
  def dump
    @logs  
  end
end
class Single_log
  attr_reader :num
  def initialize(num,receiver,method,*args)
    @num = num
    @receiver = receiver
    @method = method
    @args = args
  end
  def to_log
    #ログの内容を文字列にして吐く
    #レシーバ do メソッド名 with arguments 引数 みたいな感じをデフォとして、
    #各メソッドによっていい感じにto_sされるように書き換える
    "#{@receiver} did #{@method} with arguments #{@args.join(?,)}"
  end
end
