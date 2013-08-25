part of shared;

class CooldownSystem extends EntityProcessingSystem {
  ComponentMapper<Cooldown> cm;
  CooldownSystem() : super(Aspect.getAspectForAllOf([Cooldown]));

  void initialize() {
    cm = new ComponentMapper<Cooldown>(Cooldown, world);
  }

  void processEntity(Entity entity) {
    var c = cm.get(entity);
    c.value -= world.delta;

    if (c.value < 0.0) {
      entity.removeComponent(Cooldown);
      entity.changedInWorld();
    }
  }
}

class ExpirationSystem extends EntityProcessingSystem {
  ComponentMapper<ExpirationTimer> em;
  ExpirationSystem() : super(Aspect.getAspectForAllOf([ExpirationTimer]));

  void initialize() {
    em = new ComponentMapper<ExpirationTimer>(ExpirationTimer, world);
  }

  void processEntity(Entity entity) {
    var e = em.get(entity);
    e.time -= world.delta;

    if (e.time < 0.0) {
      entity.deleteFromWorld();
    }
  }
}

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Velocity> vm;

  MovementSystem() : super(Aspect.getAspectForAllOf([Transform, Velocity]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    vm = new ComponentMapper<Velocity>(Velocity, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var v = vm.get(entity);

    var pos = t.position;
    pos.x = pos.x - v.abs * sin(v.angle) * world.delta;
    pos.y = pos.y - v.abs * cos(v.angle) * world.delta;

    t.position = pos;
  }
}