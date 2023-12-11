import 'package:cat_water_melon_game/screen/forge2DExample.dart';
import 'package:cat_water_melon_game/screen/homeScreen.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          game: Forge2DExample()
        ),
      )
    )
  );
}
