# Azucat
* 標準入力を受け取ってブラウザに出力します
* TwitterやIRCに接続して表示することもできます
* WebSocketが動作するブラウザ + Ruby 1.8.7以上で動作します
* 今のところ接続先等の設定は ./bin/azucat に直接記述しています...

標準入力を渡す例

  $ tail -f foo.log | ./bin/azucat

twitterやIRCに接続する例

  $ ./bin/azucat


## Install
  $ gem install bundler
  $ bundler

## ScreenShot
![azucat](http://dl.dropbox.com/u/5978869/image/20120204_000517.png)
