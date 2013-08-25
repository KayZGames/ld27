part of shared;

class BulletSpawningSystem extends EntityProcessingSystem {
  ComponentMapper<Gun> gm;
  ComponentMapper<Transform> tm;
  BulletSpawningSystem() : super(Aspect.getAspectForAllOf([Gun, Transform]).exclude([Cooldown]));

  void initialize() {
    gm = new ComponentMapper<Gun>(Gun, world);
    tm = new ComponentMapper<Transform>(Transform, world);
  }

  void processEntity(Entity entity) {
    var g = gm.get(entity);
    var pos = tm.get(entity).position;
    entity.addComponent(new Cooldown(g.cooldown));
    entity.changedInWorld();
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0),
                         new Velocity(0.3, 0.0),
                         new BodyDef('bullet_${random.nextInt(4)}'),
                         new ExpirationTimer(2000.0),
                         new DestroyOnCollision(),
                         new ImpactOnCollision(),
                         new DamageOnCollision(g.damage)]);
    addNewEntity(world, [new Sound('shoot_0')]);
  }
}

class CollisionImpactSpawningSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;

  CollisionImpactSpawningSystem() : super(Aspect.getAspectForAllOf([Collision, ImpactOnCollision, Transform]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
  }

  void processEntity(Entity entity) {
    var pos = tm.get(entity).position;
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0), new BodyDef('impact_${random.nextInt(8)}'), new Effect(), new ExpirationTimer(50 + random.nextDouble() * 100)]);
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0), new BodyDef('impact_${random.nextInt(8)}'), new Effect(), new ExpirationTimer(50 + random.nextDouble() * 100)]);
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0), new BodyDef('impact_${random.nextInt(8)}'), new Effect(), new ExpirationTimer(50 + random.nextDouble() * 100)]);
    addNewEntity(world, [new Sound('collision_0')]);
  }
}

class DestructionExplosionSpawningSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;

  DestructionExplosionSpawningSystem() : super(Aspect.getAspectForAllOf([Destruction, ExplosionOnDestruction, Transform]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
  }

  void processEntity(Entity entity) {
    var pos = tm.get(entity).position;
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0), new BodyDef('explosion_${random.nextInt(8)}'), new Effect(), new ExpirationTimer(50 + random.nextDouble() * 100)]);
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0), new BodyDef('explosion_${random.nextInt(8)}'), new Effect(), new ExpirationTimer(50 + random.nextDouble() * 100)]);
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0), new BodyDef('explosion_${random.nextInt(8)}'), new Effect(), new ExpirationTimer(50 + random.nextDouble() * 100)]);
    addNewEntity(world, [new Sound('explosion_${random.nextInt(SOUNDS_EXPLOSION)}')]);
    addNewEntity(world, [new Sound('explosion_${random.nextInt(SOUNDS_EXPLOSION)}')]);
  }
}

class TruckSpawningSystem extends IntervalEntitySystem {
  TruckSpawningSystem() : super(5000, Aspect.getEmpty());

  void processEntities(_) {
    addNewEntity(world, [new Transform.w2d(random.nextDouble() * MAX_WIDTH, -20.0, PI),
                         new Velocity(0.05 + random.nextDouble() * 0.025, -PI),
                         new BodyDef('truck_0'),
                         new Health(2),
                         new ExplosionOnDestruction(),
                         new ExpirationTimer(15000.0)]);
  }
}

class PlaneSpawningSystem extends IntervalEntitySystem {
  bool active = false;
  PlaneSpawningSystem() : super(6000, Aspect.getEmpty());

  void processEntities(_) {
    addNewEntity(world, [new Transform.w2d(random.nextDouble() * MAX_WIDTH, -20.0, PI),
                         new Velocity(0.1 + random.nextDouble() * 0.05, -PI),
                         new BodyDef('plane_${random.nextInt(2)}'),
                         new Health(3),
                         new ExplosionOnDestruction(),
                         new ExpirationTimer(15000.0)]);
  }
  void activate() {
    active = true;
  }
  bool checkProcessing() => active && super.checkProcessing();
}

class TankSpawningSystem extends IntervalEntitySystem {
  bool active = false;
  TankSpawningSystem() : super(7000, Aspect.getEmpty());

  void processEntities(_) {
    addNewEntity(world, [new Transform.w2d(random.nextDouble() * MAX_WIDTH, -20.0, PI),
                         new Velocity(0.06 + random.nextDouble() * 0.04, -PI),
                         new BodyDef('tank_${random.nextInt(2)}'),
                         new Health(5),
                         new ExplosionOnDestruction(),
                         new ExpirationTimer(15000.0)]);
  }

  void activate() {
    active = true;
  }
  bool checkProcessing() => active && super.checkProcessing();
}