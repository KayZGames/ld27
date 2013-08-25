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
                         new ImpactOnCollision()]);
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
    addNewEntity(world, [new Transform.w2d(pos.x, pos.y, 0.0), new BodyDef('impact_${random.nextInt(8)}'), new Effect(), new ExpirationTimer(100.0)]);
  }
}