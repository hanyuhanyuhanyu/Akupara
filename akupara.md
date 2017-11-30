# Akuparaの使い方

### Akuparaとは

### Akuparaの概要

Akuparaはボードゲームを楽に作りたい人のために、およそ必要になるであろうクラスやメソッドをできる限り提供し、最小限の労力で望むボードゲームを作れるようにすることを目標として開発されているRuby gemです。
Akuparaを利用した場合、プレイヤーに持ち物を持たせたり、ボード上の地点にコマを置いたり、hogeした時はfugaするというような低次元の処理を書く必要性が大幅に減少します。
そのため、ボードゲーム独自のルールやより効率のよいアルゴリズム、UXの作りこみなどにリソースを投下できるようになり、結果プログラムの品質向上が期待できます。

### Akuparaの仕組み

Akuparaは次のような流れでプログラムを実行します。

1. ボードゲーム上の地点やコマ、プレイヤー、処理の流れについて定義されたjsonを読み込んでくる。

1. 製作者が独自に定義したクラスや処理を読み込む

1. 1で定義された処理の流れに則ってプログラムを実行する

以上の過程の中で、製作者がやらなければならないことは以下の二つです。

1. ボードゲーム上の地点やコマ、プレイヤー、処理の流れについてjson形式で定義する

1. jsonでは表現しきれない細かい部分についてプログラムを書く

最後の「プログラムの実行」についてはAkuparaが自動的に制御します。



### jsonでボードゲームの基本的な構造を定義する

上記にある通り、ボードゲーム上の地点やコマ、プレイヤー、処理の流れの定義自体は製作者側で行う必要があります。
その定義を書く際にはRubyプログラムを書くのではなく、json形式でその内容を定義します。
jsonでの定義によって、以下のクラスやメソッドが自動的に作られます。

1. Placeクラス => ボードゲーム上の特定の地点を示す。

1. Tokenクラス => プレイヤーのコマや、マーカーなど、ボードに置いたりプレイヤー間で渡しあうモノを表す。

1. Playerクラス => このゲームをプレイする人間を表す。

1. Gameクラスのメソッド => 記述した名前のメソッドが作られ、ごく単純な反復処理を自動的に行うようになる。

定義の仕方は次の通りです。ここではPlaceを定義する場合を例にとります。
Placeを定義する場合は、Place.jsonを作成し、次のように書き込みます。

``` json:Place.json
{
  "default_board":{
    "type":"squere",
    "row":8,
    "col":8
  }
}
```

このように書くことで、Akuparaは自動的に8×8の四角いゲーム盤を表す定数を自動生成します。チェスやオセロを作る際にはとても便利ですね。
ゲーム盤全体の情報を保有するのは、Placesという名前の定数です。
Placesはハッシュを継承しており、8×8の各マス目に当たる場所のインスタンスを参照したい場合は以下のように書きます。
ここでは2行3列目のマスに参照してみます。なお基点(0行0列目)は最も左上のマスです。

``` Ruby
Places[:r2c3] #Places[2,3]でもよい。Places[2][3]は不可。
```

各マスはPlaceクラスのインスタンスで、ボードゲームを作るうえで便利なメソッドを備えています。
例えば、チェスを作ろうと考えて、ポーンのいる7行3列目の場所の前が空いているかどうか調べたい時には、次のように書けばOKです。

``` Ruby
Places[:r7c3].up.placed? # => 何か置いてあればtrue、何も置かれていなければfalse。
```

右斜め前ならこんな感じになります。

``` Ruby
Places[:r7c3].right_up.placed? # Places[:r7c3].up.right もOK。Places[:r7c3].up_rightはNG
```

自マスと同じ行の右側全てのマスから、自分の味方のコマが置かれているものだけを取り出したい時はこう。

``` Ruby
Places[:r7c3].gather(:right){|target| target.ally?(Places[:r7c3])} # 自分自身も含まれます。
```

このように、jsonを少し書くだけで、便利な機能をたくさん使えるようになります。

Token.jsonやPlayer.jsonも同じくjsonで書きますが、そこで行われることや書き方は、説明すると長くなるので、別の機会でまとめて行うことにします。


###

