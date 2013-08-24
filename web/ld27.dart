library ld27;

import 'dart:html';

import 'package:dartemis_toolbox/system_transform.dart';
import 'package:dartemis_toolbox/utils_dartemis.dart';

import 'package:ld27/client.dart';



void main() {
  window.setImmediate(() {
    var canvas = query('canvas');
    canvas.width = MAX_WIDTH;
    canvas.height = MAX_HEIGHT;
    
    Game game = new Game(canvas);
    game.init();
    window.requestAnimationFrame(game.update);
  });
}

class Game {
  CanvasElement canvas;
  num lastTime = 0;
  World world = new World();
  Game(this.canvas);
  
  void init() {
    addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 100.0, 0.0)]);
    
    world.addSystem(new BackgroundRenderingSystem(canvas.context2D));
    
    world.initialize();
  }
  
  void update(num time) {
    world.delta = time - lastTime;
    lastTime = time;
    world.process();
    window.requestAnimationFrame(update);
  }
}