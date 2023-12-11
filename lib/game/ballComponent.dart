import 'dart:ui';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class ImageBall extends BodyComponent with ContactCallbacks{
  late final Vector2 position;
  double radius; // final 제거, 크기 변경 가능하도록
  final Sprite sprite;

  ImageBall(this.position, this.radius, this.sprite);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = const Color(0xFFFFFFFF);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0
      ..density = 10.0
      ..friction = 0.5;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position
      ..linearDamping = 0.0;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite.render(canvas, size: size, position: Vector2(-radius, -radius));
  }

  @override
  Vector2 get size => Vector2.all(radius * 2);

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    print('hi');

  }
  @override
  void endContact(Object other, Contact contact) {
    // 충돌이 끝날 때의 처리 로직
    print('충돌 끝');
  }
}
