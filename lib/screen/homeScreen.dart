import 'package:easy_physics_2d/gravity_field.dart';
import 'package:easy_physics_2d/objects.dart';
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
                    child: HomePage()
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
    print(this.getSize());
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
      // 회전 속도 설정
      double rotationSpeed = 0.1; // 회전 속도 조정 필요
      common.angle += speedX * rotationSpeed * dt; // X축 속도에 비례하여 회전
      speedX = 30;
      speedY = -0.5;
      speedY += gravity * dt; // 중력에 의한 Y축 속도 증가
      speedX *= friction; // 마찰에 의한 속도 감소
      common.position.y += speedY * dt;
      common.position.x += speedX * dt;

      // X 좌표가 화면을 벗어나지 않도록 조정
      position.x = position.x.clamp(0 + size.x / 2, gameRef.size.x - size.x / 2);

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
      if(getSize() + common.getSize() >= 100){
        print(this.getSize() + common.getSize());
        isCollide = true;
      }else if(getSize() + common.getSize() >= 75){
        print(this.getSize() + common.getSize());
        isCollide = true;
      }else if(getSize() + common.getSize() >= 25){
        print(this.getSize() + common.getSize());
        isCollide = true;
      }
      else{
        isCollide = false;
      }
    }else{
      isCollide = false;
    }


    // 충돌 발생 시 수행할 작업
  }
}



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double sliderValue = 1000;

  Paint paint1 = Paint()
    ..color = Color(0xff263e63)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Paint paint2 = Paint()
    ..color = Color(0xff15693b)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  List<Paint> paintList = [];
  List<dynamic> objList = [];

  Path draw1 = Path();
  Path draw2 = Path();

  Path draw3 = Path();
  Path draw4 = Path();

  var ball;
  var ball2;
  var ball3;


  @override
  void initState() {
    super.initState();

    for (double i = 0; i < 20 - 1; i++) {
      draw1.arcTo(
          Rect.fromCircle(
            radius: i,
            center: Offset(
              0,
              0,
            ),
          ),
          0 ,
          (1.5 * pi),
          true);

      draw2.arcTo(
          Rect.fromCircle(
            radius: i,
            center: Offset(
              0,
              0,
            ),
          ),
          1.5 * pi ,
          0.5 * pi,
          true);

      draw3.arcTo(
          Rect.fromCircle(
            radius: i,
            center: Offset(
              0,
              0,
            ),
          ),
          0 ,
          (1.5 * pi),
          true);

      draw4.arcTo(
          Rect.fromCircle(
            radius: i,
            center: Offset(
              0,
              0,
            ),
          ),
          1.5 * pi ,
          0.5 * pi,
          true);
    }

    paintList=[paint1, paint2];
    ball = myBall(
        xPoint: 15,
        yPoint: 0,
        xVelocity: 0,
        yVelocity: 0,
        ballRadius: 30,
        ballMass: 0.5,
        angularVelocity: 0,
        ballPaint: paintList
    );






    objList = [ball];
  }

  @override
  Widget build(BuildContext context) {
    //print(objList.length);
    return Scaffold(
      body: _buldBody(),
    );
  }

  Widget _buldBody() {
    //print(ball.xPos);



    return Container(

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Flutter Physics",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  color: Colors.black45),
            ),

            Container(
              child: GravityField(
                objects: objList,
                gravity: 720,
                mapX: 350,
                mapY: 500,
                mapColor: colorLibrary.mapColor,

              ),
              padding: EdgeInsets.all(1),
            ),



          ],
        ),
      )
    );
  }
}

class colorLibrary {
  static Color mainColor2 = const Color.fromARGB(255, 255, 248, 235);
  static Color mapColor = const Color(0xffefe0c3);
  static Color mainColor = const Color.fromARGB(255, 214, 237, 255);
  static Color buttonColor = const Color(0xffffd6a9);
}
