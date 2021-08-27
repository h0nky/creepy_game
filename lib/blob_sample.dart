import 'dart:math' as math;
import 'package:flame/parallax.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame/palette.dart';
import 'boundaries.dart';
import 'dart:ui';

class Ground extends BodyComponent {
  final Vector2 worldCenter;

  Ground(this.worldCenter);

  @override
  Body createBody() {
    PolygonShape shape = PolygonShape();
    shape.setAsBoxXY(20.0, 0.4);

    BodyDef bodyDef = BodyDef();
    bodyDef.position.setFrom(worldCenter);
    final ground = world.createBody(bodyDef);
    ground.createFixtureFromShape(shape);

    shape.setAsBox(0.4, 20.0, Vector2(-10.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);
    shape.setAsBox(0.4, 20.0, Vector2(10.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);
    return ground;
  }
}

class BlobPart extends BodyComponent {
  final ConstantVolumeJointDef jointDef;
  final int bodyNumber;
  final Vector2 blobRadius;
  final Vector2 blobCenter;

  BlobPart(
    this.bodyNumber,
    this.jointDef,
    this.blobRadius,
    this.blobCenter,
  );

  @override
  Body createBody() {
    final nBodies = 10.0;
    final bodyRadius = 2.0;
    final angle = (bodyNumber / nBodies) * math.pi * 2;
    final x = blobCenter.x + blobRadius.x * math.sin(angle);
    final y = blobCenter.y + blobRadius.y * math.cos(angle);

    BodyDef bodyDef = BodyDef()
      ..fixedRotation = true
      ..position.setValues(x, 0)
      ..type = BodyType.dynamic;
    Body body = world.createBody(bodyDef);

    CircleShape shape = CircleShape()..radius = bodyRadius;
    FixtureDef fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..filter.groupIndex = -2;
    body.createFixture(fixtureDef);
    jointDef.addBody(body);
    return body;
  }
}

class FallingBox extends BodyComponent {
  Paint originalPaint = BasicPalette.blue.paint();
  final Vector2 position;

  FallingBox(this.position) {
    this.paint = originalPaint;
  }

  @override
  Body createBody() {
    BodyDef bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;

    bodyDef.linearVelocity = Vector2(0, 20);
    PolygonShape shape = PolygonShape()..setAsBoxXY(2, 4);
    Body body = world.createBody(bodyDef);
    body.createFixtureFromShape(shape, 1.0);
    return body;
  }
}

class BlobSample extends Forge2DGame with TapDetector {
  BlobSample() : super(gravity: Vector2(0, -30.0));

  final _imageNames = [
    ParallaxImageData('parallax/bg.png'),
    ParallaxImageData('parallax/mountain-far.png'),
    ParallaxImageData('parallax/mountains.png'),
    ParallaxImageData('parallax/trees.png'),
    ParallaxImageData('parallax/foreground-trees.png'),
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final worldCenter = screenToWorld(size * camera.zoom / 2);
    final blobCenter = Vector2(20, 20);
    final blobRadius = Vector2.all(5.0);
    addAll(createBoundaries(this));
    // add(Ground(Vector2(worldCenter.x, -50)));
    final jointDef = ConstantVolumeJointDef()
      ..frequencyHz = 20.0
      ..dampingRatio = 1.0
      ..collideConnected = false;

    final parallax = await loadParallaxComponent(
      _imageNames,
      baseVelocity: Vector2(5, 0),
      velocityMultiplierDelta: Vector2(1.2, 1.0),
    );
    add(parallax);

    await Future.wait(List.generate(
      20,
      (i) => add(BlobPart(i, jointDef, blobRadius, blobCenter)),
    ));
    world.createJoint(jointDef);
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    // final worldCenter = screenToWorld(size * camera.zoom / 2);
    // camera.moveTo(details.eventPosition.game - worldCenter);
    add(FallingBox(details.eventPosition.game));
  }
}
