import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

void main() {
  // MyApp を呼び出す
  runApp(HelloPage());
}

class HelloPage extends StatelessWidget {
  HelloPage({super.key});

  final game = PhysicsGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}

/*
 * 外枠の構築
 */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /*
   * build
   */
  @override
  Widget build(BuildContext context) {
    // 3. タイトルとテーマを設定する。画面の本体はMyHomePageで作る。
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/*
 * 画面内部の構築
 */
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/*
 * 画面内部状態／処理
 */
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final listItems = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 3',
    'Item 3',
    'Item 3',
    'Item 3',
    'Item 3',
    'Item last',
  ];

  /*
   * カウンタ押下処理
   */
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /*
   * build
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面上部のタイトル部分
      appBar: AppBar(
        // 左側のアイコン
        leading: Icon(Icons.arrow_back),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Hello!"),
        // 右側のアイコン一覧
        actions: <Widget>[
          IconButton(
            onPressed: () => print("押下→favorite"),
            icon: Icon(Icons.favorite),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 画面の中央に表示されるテキスト
            const Text(
              'You have pushed the button this many times:',
            ),
            // テキストの下に表示されるカウンタ値
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () => print("押下確認A"),
              child: Text('TextButton'),
            ),
            ElevatedButton(
              onPressed: () {/* ボタンがタップされた時の処理 */},
              child: Text('ElevatedButton'),
            ),
            Container(
              // width: Match,
              width: 200,
              // 背景色
              color: Colors.blue,
              child: const Text(
                'Text test1',
                style: TextStyle(color: Color.fromARGB(255, 243, 243, 243)),
                textAlign: TextAlign.right,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('first row'),
                Text('second row'),
                Text('third row'),
              ],
            ),
            IconButton(
              onPressed: () {},
              // 表示アイコン
              icon: const Icon(Icons.thumb_up),
              // アイコン色
              color: Colors.red,
              // サイズ
              iconSize: 32,
            ),
            Container(
              height: 125,
              padding: EdgeInsets.all(4),
              // childrenを指定してリスト表示
              child: ListView(
                children: <Widget>[
                  Container(
                    height: 50,
                    color: Colors.blue[600],
                    child: Text('Item 1'),
                  ),
                  Container(
                    // height: 50,
                    color: Colors.blue[300],
                    child: Text('Item 2\ntestA'),
                  ),
                  Container(
                    height: 50,
                    color: Color.fromARGB(255, 17, 79, 10),
                    child: Text('Item 3'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 右下の「+」ボタンに対応するフローティングアクションボタン
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        backgroundColor: Colors.green,
        tooltip: 'Increment', // アクション説明用テキスト
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class PhysicsGame extends Forge2DGame with TapCallbacks {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final rect = camera.visibleWorldRect;

    await world.add(
      Wall(pos: rect.bottomLeft.toVector2(), size: Vector2(rect.width, 1)),
    );
    await world.add(
      Wall(pos: rect.topLeft.toVector2(), size: Vector2(1, rect.height)),
    );
    await world.add(
      Wall(pos: rect.topRight.toVector2(), size: Vector2(1, rect.height)),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    world.add(
      Ball(pos: screenToWorld(event.localPosition)),
    );
  }
}

/*
 * 壁
*/
class Wall extends BodyComponent {
  Wall({required this.pos, required this.size})
      : super(paint: BasicPalette.gray.paint());

  final Vector2 pos;
  final Vector2 size;

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(size.x, size.y, pos, 0);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(userData: this);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

/*
 * ボール
*/
class Ball extends BodyComponent with TapCallbacks {
  Ball({required this.pos});

  final Vector2 pos;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 2;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.8,
      density: 1.0,
      friction: 0.4,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: pos,
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);

    canvas.drawLine(
      center,
      center + Offset(0, radius),
      BasicPalette.black.paint(),
    );

    final Paint paintBorder = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, radius, paintBorder);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    print("タッチされました");
  }
}
