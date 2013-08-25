library ld27;

import 'dart:async';
import 'dart:math';

import 'package:ld27/client.dart';

void main() {
  window.setImmediate(() {
    var canvas = query('canvas');
    canvas.width = MAX_WIDTH;
    canvas.height = MAX_HEIGHT;

    Future.wait([loadSpritesheet('../assets/img/assets'), loadPolygons('../assets/img/assets')]).then((result) {
      Game game = new Game(canvas, result[0], result[1]);
      game.init();

      window.requestAnimationFrame(game.update);
    });

  });
}

class Game {
  CanvasElement canvas;
  SpriteSheet sheet;
  Map<String, List<Polygon>> bodyDefs;
  num lastTime = 0;
  World world = new World();
  Game(this.canvas, this.sheet, this.bodyDefs);

  void init() {
    bodyDefs.forEach((bodyId, shapes) {
      var offset = sheet.sprites['$bodyId.png'].offset;
      shapes.forEach((shape) {
        shape.vertices = shape.vertices.map((vertex) => vertex + offset).toList();
      });
    });

    var tm = new TagManager();
    world.addManager(tm);
    world.addManager(new PlayerManager());

    var entity = addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 100.0, 0.0), new Velocity(0.0, 0.0), new BodyDef('ship_0')]);
    addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 165.0, 0.0), new Velocity(0.0, 0.0), new Gun(500.0)], player: PLAYER_1);
    addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, 0.0, 0.0), new Velocity(0.1, -PI), new BodyDef('truck_0')]);

    tm.register(entity, PLAYER_1);

    // Input
    world.addSystem(new MouseInputHandlingSystem(canvas));
    // Logic
    world.addSystem(new MovementSystem());
    world.addSystem(new CollisionDetectionSystem(bodyDefs));
    world.addSystem(new CollisionImpactSpawningSystem());
    world.addSystem(new DestroyOnCollisionSystem());
    world.addSystem(new BulletSpawningSystem());
    world.addSystem(new CooldownSystem());
    world.addSystem(new ExpirationSystem());
    // Rendering
    world.addSystem(new BackgroundRenderingSystem(canvas.context2D, sheet));
    world.addSystem(new EntityRenderingSystem(canvas.context2D, sheet));
//    world.addSystem(new DebugBodyDefRenderingSystem(canvas.context2D, sheet, bodyDefs));

    world.initialize();
  }

  void update(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.requestAnimationFrame(update);
  }
}