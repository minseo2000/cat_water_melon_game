import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/widgets.dart';

import '../game/ballComponent.dart';


class Forge2DExample extends Forge2DGame with TapDetector, PanDetector, ContactCallbacks{

  List<ImageBall> ballList = [];

  late ImageBall movingBall;
  late Sprite ballSprite;
  late ImageBall currentImageBall;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 이미지 리소스 로드
    final image = await Flame.images.load('big1.png');
    ballSprite = Sprite(image);
    world.setMounted();
    // 충돌 감지 설정
    // ContactListener 설정

    ballList = [
      ImageBall(Vector2(10,50.0), 1.0, ballSprite),
      ImageBall(Vector2(10,50.0), 2.0, ballSprite),
      ImageBall(Vector2(10,50.0), 3.0, ballSprite),
      ImageBall(Vector2(10,50.0), 4.0, ballSprite),
      ImageBall(Vector2(10,50.0), 5.0, ballSprite),
      ImageBall(Vector2(10,50.0), 10.0, ballSprite),
      ImageBall(Vector2(10,50.0), 15.0, ballSprite),
      ImageBall(Vector2(10,50.0), 20.0, ballSprite),
    ];
    world.gravity = Vector2(0, 60);
    camera.viewport.add(FpsTextComponent());
    world.addAll(createBoundaries());
    world.add(ballList[0]);
    world.add(ballList[1]);
    world.add(ballList[2]);
    world.add(ballList[3]);
    world.add(ballList[4]);
  }


  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    // 현재 공을 새로운 위치에 생성
    currentImageBall = ImageBall(Vector2(10,50.0), 4.0, ballSprite);

    world.add(currentImageBall!);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    super.onPanUpdate(info);
    moveBallTo(info.eventPosition.global.toOffset());
  }


  void moveBallTo(Offset position) {
    final touchPosition = screenToWorld(Vector2(position.dx, 50.0));

    // 현재 공의 위치를 업데이트
    if (currentImageBall != null) {
      currentImageBall!.body.setTransform(touchPosition, 0);
    }
  }



}

class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3, restitution: 0);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class ImageBallContactCallback extends ContactCallbacks{
  @override
  void begin(ImageBall ball1, ImageBall ball2, Contact contact) {
    // 여기에 ImageBall 간의 충돌이 발생했을 때의 로직을 추가하세요.
  }
}
