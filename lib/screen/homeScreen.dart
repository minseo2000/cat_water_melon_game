import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      top: 5.0,
                      bottom: 10.0
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: Text('냐옹 수박게임', style: TextStyle(fontSize: 20.0),),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                              child: Text('점수', style: TextStyle(fontSize: 20.0),),
                          ),
                        ),
                      ],
                    )
                  ),
                ),
                Expanded(
                  flex: 90,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Colors.black
                        )
                      )
                    ),
                    child: GameWidget(
                      game: MyGame(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(),
                ),

              ],
            )
        ),
      )
    );
  }
}

List<MyDraggableImage> ballCom = [];

MyDraggableImage common = MyDraggableImage()
  ..size = Vector2(200, 200)
  ..position = Vector2(100, 100); // 터치된 위치로 설정

class MyGame extends FlameGame with TapCallbacks, DragCallbacks, HasCollisionDetection, CollisionCallbacks {

  Color backgroundColor() => Colors.white;
  // height  = 10

  late SpriteComponent player;
  late MyDraggableImage draggableImage;

  dynamic currentPosition = Vector2(100, 100);

  @override
  Future<void> onLoad() async {

    super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) async{
    if(common.isFalling == false){
      common = new MyDraggableImage()
        ..size = Vector2(100, 100)
        ..position = Vector2(100, 100); // 터치된 위치로 설정
      add(common);
      ballCom.add(common);
      print(ballCom);
    }else{
      return;
    }
  }
  @override
  void onTapUp(TapUpEvent event) async{
    if(common.isFalling == false){
      common.isFalling = true;
    }
  }


  @override
  void onDragUpdate(DragUpdateEvent event) {
    // TODO: implement onDragStart
    if(common.isFalling == false){



      currentPosition = event.canvasPosition;
      if(currentPosition.x - common.getSize() < 0){
        common.position = Vector2(currentPosition.x +common.getSize(), 100);
      }else if(currentPosition.x + common.getSize() > size.x){
        common.position = Vector2(currentPosition.x - common.getSize(), 100);
      }else{
        common.position = Vector2(currentPosition.x, 100);
      }

    }
  }
  @override
  void onDragEnd(DragEndEvent event) {
    common.isFalling = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

  }
}

class MyDraggableImage extends SpriteComponent with HasGameRef<MyGame>, DragCallbacks, TapCallbacks, CollisionCallbacks {

  List<String> imgList = [
    'big1.png',
    'big7.png'
  ];

  double speedX = 0;
  double speedY = 0;
  double gravity = 500; // 중력 가속도
  double friction = 0.95; // 마찰 계수

  MyDraggableImage({Sprite? sprite, Vector2? size}) : super(sprite: sprite, size: size ?? Vector2(50, 50)) {
    anchor = Anchor.center;
  }

  bool isFalling = false;
  bool isCollide = false;

  late double imgSize;
  @override
  Future<void> onLoad() async {
    int random_num = Random().nextInt(2);
    sprite = await gameRef.loadSprite(imgList[random_num]);
    if(random_num == 0){
      imgSize = 50;
      size = Vector2(imgSize, imgSize);
    }else if(random_num == 1){
      imgSize = 100;
      size = Vector2(imgSize, imgSize);
    }
    print(random_num);
    add(CircleHitbox());

  }
  double getSize(){
    return imgSize/2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 굴러가는 움직임 구현
    if (isFalling) {
      speedY += gravity * dt;  // 중력에 의한 Y축 속도 증가
      position.y += speedY * dt;
      position.x += speedX * dt;

      // X 좌표가 화면을 벗어나지 않도록 조정
      position.x = position.x.clamp(0 + size.x / 2, gameRef.size.x - size.x / 2);


      // 화면 바닥에 닿으면 멈춤
      if (position.y > gameRef.size.y - size.y / 2) {
        isFalling = false;
        speedY = 0;
        position.y = gameRef.size.y - size.y / 2; // 바닥에 위치 조정
      }
    }
    if(isCollide) {
      // 충돌 방지를 위한 위치 조정
      // 충돌 방지를 위한 위치 조정
      Vector2 collisionDirection = (common.position + position).normalized();
      common.position.add(collisionDirection * 10); // 예시: 10 픽셀만큼 밀어냄
      // 화면 경계 처리
      if (position.x < size.x / 2) {
        position.x = size.x / 2;
        speedX = -speedX; // 반대 방향으로 튕김
      }
      if (position.x > gameRef.size.x - size.x / 2) {
        position.x = gameRef.size.x - size.x / 2;
        speedX = -speedX; // 반대 방향으로 튕김
      }

      // 바닥에 닿으면 멈춤
      if (position.y > gameRef.size.y - size.y / 2) {
        isCollide = false;
        speedY = 0;
        position.y = gameRef.size.y - size.y / 2;
      }else{
        isCollide = false;
      }
      print('충돌');
    }

  }
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if(isCollide == false){
      isCollide = true;
    }else{
      isCollide = false;
    }


    // 충돌 발생 시 수행할 작업
  }
}