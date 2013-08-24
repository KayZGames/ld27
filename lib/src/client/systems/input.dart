part of client;

class MouseInputHandlingSystem extends VoidEntitySystem {
  CanvasElement canvas;
  Point mousePos;
  PlayerManager pm;
  TagManager tagManager;
  ComponentMapper<Velocity> vm;
  ComponentMapper<Transform> tm;

  MouseInputHandlingSystem(this.canvas);

  void initialize() {
    pm = world.getManager(PlayerManager);
    tagManager = world.getManager(TagManager);

    vm = new ComponentMapper<Velocity>(Velocity, world);
    tm = new ComponentMapper<Transform>(Transform, world);

    canvas.onMouseMove.listen(handleMouseMove);
  }

  void processSystem() {
    if (null != mousePos) {
      var player = tagManager.getEntity(PLAYER_1);
      var vel = vm.get(player);
      var pos = tm.get(player).position;
      var diff = pos.x - mousePos.x;
      if (diff > 5) {
        vel.angle = PI/2;
        vel.abs = 0.25;
      } else if (diff < -5) {
        vel.angle = -PI/2;
        vel.abs = 0.25;
      } else {
        vel.angle = 0.0;
        vel.abs = 0.0;
      }
      pm.getEntitiesOfPlayer(PLAYER_1).forEach((entity) {
        var otherVel = vm.getSafe(entity);
        if (null != otherVel) {
          otherVel.abs = vel.abs;
          otherVel.angle = vel.angle;
        }
      });
    }
  }

  void handleMouseMove(MouseEvent event) {
    mousePos = CqTools.mousePosition(event);
  }
}