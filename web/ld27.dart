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
      Game game = new Game(canvas, new LayeredSpriteSheet(result[0]), result[1]);
      game.init();

      window.requestAnimationFrame(game.initialUpdate);
    });

  });
}

class Game {
  CanvasElement canvas;
  LayeredSpriteSheet sheet;
  Map<String, List<Polygon>> bodyDefs;
  num lastTime = 0;
  World world = new World();
  Game(this.canvas, this.sheet, this.bodyDefs);

  void init() {
    bodyDefs.forEach((bodyId, shapes) {
      var offset = sheet.getLayerFor('$bodyId.png').sprites['$bodyId.png'].offset;
      shapes.forEach((shape) {
        shape.vertices = shape.vertices.map((vertex) => vertex + offset).toList();
      });
    });

    var tm = new TagManager();
    world.addManager(tm);
    world.addManager(new PlayerManager());

    var entity = addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 100.0, 0.0), new Velocity(0.0, 0.0), new BodyDef('ship_0')]);
    addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 165.0, 0.0), new Velocity(0.0, 0.0), new Gun(1, 500.0)], player: PLAYER_1);


    tm.register(entity, PLAYER_1);

    // Input
    world.addSystem(new MouseInputHandlingSystem(canvas));
    // Logic
    world.addSystem(new MovementSystem());
    world.addSystem(new CollisionDetectionSystem(bodyDefs));
    world.addSystem(new DestroyOnCollisionSystem());
    world.addSystem(new DestructionSystem());
    world.addSystem(new DamageToHealthSystem());
    world.addSystem(new CooldownSystem());
    world.addSystem(new ExpirationSystem());
    // spawning
    world.addSystem(new CollisionImpactSpawningSystem());
    world.addSystem(new DestructionExplosionSpawningSystem());
    world.addSystem(new BulletSpawningSystem());
    world.addSystem(new TruckSpawningSystem());
    // Rendering
    world.addSystem(new BackgroundRenderingSystem(canvas.context2D, sheet));
    world.addSystem(new EntityRenderingSystem(canvas.context2D, sheet));
//    world.addSystem(new DebugBodyDefRenderingSystem(canvas.context2D, sheet, bodyDefs));

    world.initialize();

    new Timer(new Duration(seconds: 10), () {
      loadSpritesheet('../assets/img/assetsv1').then((layer) {
        sheet.add(layer);
        BackgroundRenderingSystem bgSys = world.getSystem(BackgroundRenderingSystem);
        bgSys.prepareBackground(1);
      });
    });
  }

  void initialUpdate(num time) {
    world.delta = 16.66;
    lastTime = time;
    world.process();
    window.requestAnimationFrame(update);
  }

  void update(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.requestAnimationFrame(update);
  }
}