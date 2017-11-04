# Akuparaリファレンス

## 設計思想

Akuparaは、以下のごく少数のものを基本として、ボードゲームを構成する。

* ヒトやモノを表現するためのもの（クラス）
	* BaseObject => 全てのクラスのベースとなるクラス。Place,Player,Tokenは全てこれを継承している
	* Place => ボードゲーム上の位置などを表現するためのクラス。Place間の隣接関係を管理することに特化している。
	* Player => ボードゲームを遊ぶ人間を表現するためのクラス。以下に続くTokenの管理をする場合に有用である。
	* Token => ボードゲームで使い、やり取りされるものを表現するためのクラス。Placeに置かれたり、Playerが保持されたりする。
* 処理やイベントを表現するためのもの（メソッド）
	* init => ゲーム開始時に行う処理を定めるためのもの。拡張ルールの設定、各プレイヤーの順番の決定、初期配置などの処理を行うことを想定。
	* iterate => ゲームプレイ中に行う処理を定めるためのもの。多くのボードゲームは、似たような動きの繰り返しから成立しているが、それを管理する。
	* close => ゲーム終了時の処理を定めるためのもの。最後の交渉、得点計算、勝者の決定などの処理を行うことを想定。

jsonファイルを適切な形式で書くことで、これらのクラスやメソッドに属するインスタンス/クラス/メソッドを定義することができる。

例えば、Akupara/bin/objects/def/Place.jsonに以下のように書けば、Akuparaは、America/Canada/Mexicoという名前のインスタンスを自動生成する。各インスタンスは、それぞれ、jsonファイルで指定されたnameと隣接関係を記憶している。

```json:Place.json
{
	"america":{
    	"name":"United States of America",
        "adjs":["canada","brazil"] //adjsはadjacents(隣接)の略。
	},
    "canada":{
    	"name":"Canada",
        "adjs":[""] //america <=> canadaの隣接関係は、americaが知っているため、canada側に同じ記述をしなくてもよい。
    },
    "mexico":{
    	"name":"Mexico",
        "adjs":["america"] //明記してもよい。タイプミスのリスクが増えるので非推奨ではあるが。
    }
}
```

Americaと打つだけでなく、Places[:america]としても、コード中でamericaのインスタンスを参照できる。これらはPlaceクラスのインスタンスであり、

他のクラス/メソッドについても同様に、json形式でインスタンスやクラスの定義を決定できる。以下に、各クラス/メソッドにおけるjsonの書き方と、プログラム内での使い方について詳説する。

## 各クラスのjsonの書き方/メソッド/使い方など

BaseObject以外のクラスも、(クラス名).jsonをbin/objects/def/直下に置くことで、Akuparaが読み込む対象となる。

### BaseObject

以下の続く全てのクラスの親クラスである。このクラスだけは、定義を読み込むためのjsonファイルを持たない。
BaseObjectの持つメソッドは次の通りである。

<dl>
  <dt>

  ##### クラスインスタンス変数
  </dt>
  <dd>
    <dl>
      <dt>@count</dt>
      <dd>シンボル名が登録されていないインスタンスに大して、to_symでシンボル名を呼ぼうとすると、undefined_連番でシンボル名をその場で名付ける使用となっている。この時の連番を管理するのがこの@countである。
      </dd>
    </dl>
  </dd>
</dl>

<dl>
  <dt>

  ##### インスタンス変数
  </dt>
  <dd>
  いずれも
    <dl>
      <dt>@to_sym</dt>
      <dd>シンボルで呼ぶ際の名前を保持する。
      </dd>
      <dt>@where</dt>
      <dd>インスタンスが、どのPlace上にあるかを保持する。</dd>
      <dt>@hold</dt>
      <dd>インスタンスが持っている、Tokenを保持する。</dd>
    </dl>
  </dd>
</dl>

<dl>
<dt>

##### クラスメソッド

</dt>
<dd>
  <dl>
  <dt>addcount</dt>
  <dd>各インスタンスは基本的にシンボルによって固有名を保持しているが、それを持たないのにシンボル名を要求された場合は@countの値を元に、シンボル名を即席で付与する。この時、@countの値を返した上で、@countの値を1増すのがaddcountメソッドである。</dd>
  </dl>
</dd>
</dl>

<dl>
<dt>

##### インスタンスメソッド
</dt>
<dd>
	<dl>
	    <dt>parachute(place)</dt>
        <dd>そのインスタンスを、ある場所をplaceに設定する。隣接関係など一切の考慮なしに置く。placeがPlaceクラスでなければ、何もしない。</dd>
	    <dt>hold(token)</dt>
        <dd>そのインスタンスに、tokenを持たせる。tokenがTokenクラスでなければ、何もしない。</dd>
	    <dt>[](token)</dt>
        <dd>そのインスタンスの保持するtokenを参照する。</dd>
    </dl>
</dd>

</dl>

jsonは書かない。



### Place

### Player

### Tokne
