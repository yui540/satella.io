# satella.io
「satella.io」は、イラストに「命」を吹き込むソフトウェアです。

現在、Webサービスとしてブラウザで動作する「[satella.io](http://satella.io)」を開発中です。

2018/02/01に公開予定でしたが、WebGLをきちんと学びなおしたいので公開を延期させていただきます。

できる限り、良いサービスにできるように開発を続けさせていただきます。

※現在公開しているのは、Electron版の過去のバージョンです。

![preview1](sample/s1.png)


- デモ動画
  - [Twitter - 「satella.io」のデモ動画](https://twitter.com/eriri_jp/status/828140972429029376)
- 開発者
  - yuki540
  - [Twitter - @eriri_jp](https://twitter.com/eriri_jp)
  - [HP - yuki540.com](http://yuki540.com)
  
## セットアップ
ベータ版なので不完全ですが、お試しで動かしたい方は下記の通りに試してください。

#### clone
```
git clone https://github.com/yuki540net/satella.io.git && cd satella.io
```

#### yarn install
```
yarn install
```

#### 起動
```
yarn start
```

起動したら、右から２番目のアップロードボタンのようなアイコンのボタンをクリックし、satella.ioフォルダのmodel_dataを読み込んでください。
これで、モデリングされたキャラが見られます。

## 「Live2Dライクなオープンソースソフトウェアの開発」という挑戦。

「イラストに命を吹き込む」技術を個人で開発し、オープンソースとして公開することは、私にとってとてもいい経験になりました。

3D技術の知識ゼロから始めたもので、お粗末な出来ですが、誰かにとっての技術的なヒントになることを祈ります。

satella.ioは、Webサービスとして動作するように開発を進めています。

#### さらなる進化にご期待を。

## ポリゴンを制御することでキャラが動いているように見せる
### 瞬きを表現
![preview2](sample/s2.png)

### 上下左右の動きを表現
![preview3](sample/s3.png)

### 複数パターンの動きを生み出す
![preview4](sample/s4.png)

## satella.ioのこれから
Webブラウザで動作する「[satella.io](http://satella.io)」にご期待を。
![preview5](sample/s5.png)

## ライセンスについて
このソフトウェアは、MIT Licenseのもとで公開されています。
