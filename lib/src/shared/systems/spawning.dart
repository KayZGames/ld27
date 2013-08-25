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
                         new Velocity(0.4, 0.0),
                         new BodyDef('bullet_${random.nextInt(4)}'),
                         new ExpirationTimer(2000.0),
                         new DestroyOnCollision(),
                         new ImpactOnCollision(),
                         new DamageOnCollision(g.damage)]);
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
  }
}

class TruckSpawningSystem extends IntervalEntitySystem {
  TruckSpawningSystem() : super(10000, Aspect.getEmpty());

  void processEntities(_) {
    addNewEntity(world, [new Transform.w2d(random.nextDouble() * MAX_WIDTH, -20.0, 0.0), new Velocity(0.1, -PI), new BodyDef('truck_0'), new Health(3), new ExplosionOnDestruction()]);
  }
}