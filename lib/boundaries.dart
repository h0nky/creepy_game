import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flame/palette.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/body_component.dart';

List<Wall> createBoundaries(Forge2DGame game) {
  final Vector2 topLeft = Vector2.zero();
  final Vector2 bottomRight = game.screenToWorld(game.viewport.effectiveSize);
  final Vector2 topRight = Vector2(bottomRight.x, topLeft.y);
  final Vector2 bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    Wall(topLeft * 0.8, topRight * 0.8),
    Wall(topRight * 0.8, bottomRight * 0.8),
    Wall(bottomRight * 0.8, bottomLeft * 0.8),
    Wall(bottomLeft * 0.8, topLeft * 0.8),
  ];
}

class Wall extends BodyComponent {
  Paint paint = BasicPalette.white.paint();
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.0
      ..friction = 0.3;

    final bodyDef = BodyDef()
      ..userData = this // To be able to determine object in collision
      ..position = Vector2.zero()
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
