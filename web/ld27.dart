library ld27;

import 'dart:async';

import 'package:dartemis_toolbox/utils_dartemis.dart';

import 'package:ld27/client.dart';



void main() {
  window.setImmediate(() {
    var canvas = query('canvas');
    canvas.width = MAX_WIDTH;
    canvas.height = MAX_HEIGHT;

    loadSpritesheet('../assets/img/assets').then((spriteSheet) {
      Game game = new Game(canvas, spriteSheet);
      game.init();

      window.requestAnimationFrame(game.update);
    });

  });
}

class Game {
  CanvasElement canvas;
  SpriteSheet sheet;
  num lastTime = 0;
  World world = new World();
  Game(this.canvas, this.sheet);

  void init() {
    addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 100.0, 0.0), new Drawable(sheet.sprites['ship_0.png'])]);

    world.addSystem(new BackgroundRenderingSystem(canvas.context2D, sheet));
    world.addSystem(new EntityRenderingSystem(canvas.context2D, sheet));

    world.initialize();
  }

  void update(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.requestAnimationFrame(update);
  }
}