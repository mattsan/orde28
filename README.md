# Orde28

[横浜へなちょこプログラミング勉強会](https://yhpg.doorkeeper.jp) の [オフラインリアルタイムどう書くE28](https://yhpg.doorkeeper.jp/events/81346) で出題された [増築の果ての隣室 2018.11.3](http://nabetani.sakura.ne.jp/hena/orde28sqst/) を Elixir で解きました。

## 実行方法

リポジトリを clone します。

```
$ git clone git@github.com:mattsan/orde28.git
```

依存しているパッケージを取得してコンパイルします。

```
$ mix do deps.get, deps.compile
```

[どう書くテストランナ](https://github.com/mattsan/ex_doukaku) のコマンドでテストを実行します。

```
$ mix doukaku.test
```

特定のテストケースを実行する場合は `-n` オプションで指定します。

```
$ mix doukaku.test -n 1,2,3 # テストケース 1, 2, 3 を実行する
```

コンマで区切る場合は番号やコンマの間にスペースなどを入れる場合は引用符でくくってください。

```
$ mix doukaku.test -n '1, 2, 3'
```
