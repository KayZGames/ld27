part of shared;

class CooldownSystem extends EntityProcessingSystem {
  Mapper<Cooldown> cm;
  CooldownSystem() : super(Aspect.getAspectForAllOf([Cooldown]));

  void initialize() {
    cm = new Mapper<Cooldown>(Cooldown, world);
  }

  void processEntity(Entity entity) {
    var c = cm[entity];
    c.value -= world.delta;

    if (c.value < 0.0) {
      entity.removeComponent(Cooldown);
      entity.changedInWorld();
    }
  }
}

class ExpirationSystem extends EntityProcessingSystem {
  Mapper<ExpirationTimer> em;
  ExpirationSystem() : super(Aspect.getAspectForAllOf([ExpirationTimer]));

  void initialize() {
    em = new Mapper<ExpirationTimer>(ExpirationTimer, world);
  }

  void processEntity(Entity entity) {
    var e = em[entity];
    e.time -= world.delta;

    if (e.time < 0.0) {
      entity.deleteFromWorld();
    }
  }
}

class MovementSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  Mapper<Velocity> vm;

  MovementSystem() : super(Aspect.getAspectForAllOf([Transform, Velocity]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
    vm = new Mapper<Velocity>(Velocity, world);
  }

  void processEntity(Entity entity) {
    var t = tm[entity];
    var v = vm[entity];

    var pos = t.position;
    pos.x = pos.x - v.abs * sin(v.angle) * world.delta;
    pos.y = pos.y - v.abs * cos(v.angle) * world.delta;

    t.position = pos;
  }
}

class DamageToHealthSystem extends EntityProcessingSystem {
  Mapper<Health> hm;
  Mapper<Damage> dm;
  DamageToHealthSystem() : super(Aspect.getAspectForAllOf([Health, Damage]));

  void initialize() {
    hm = new Mapper<Health>(Health, world);
    dm = new Mapper<Damage>(Damage, world);
  }

  void processEntity(Entity entity) {
    var h = hm[entity];
    var d = dm[entity];

    h.currentHealth -= d.value;

    entity.removeComponent(Damage);
    if (h.currentHealth <= 0) {
      entity.addComponent(new Destruction());
    }
    entity.changedInWorld();
  }
}

class DestructionSystem extends EntityProcessingSystem {
  DestructionSystem() : super(Aspect.getAspectForAllOf([Destruction]));
  void processEntity(Entity entity) => entity.deleteFromWorld();
}
