part of shared;

class CollisionDetectionSystem extends EntitySystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<BodyDef> bm;
  Map<String, List<Polygon>> bodyDefs;

  CollisionDetectionSystem(this.bodyDefs) : super(Aspect.getAspectForAllOf([Transform, BodyDef]).exclude([Effect]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    bm = new ComponentMapper<BodyDef>(BodyDef, world);
  }

  void processEntities(ReadOnlyBag<Entity> entities) {
    int size = entities.size;
    if (size > 1) {
      for (int i = 0; i < entities.size - 1; i++) {
        for (int j = i + 1; j < entities.size; j++) {
          var entity1 = entities[i];
          var entity2 = entities[j];

          var pos1 = tm.get(entity1).position;
          var pos2 = tm.get(entity2).position;

          var bodyId1 = bm.get(entity1).bodyId;
          var bodyId2 = bm.get(entity2).bodyId;

          var shapes1 = bodyDefs[bodyId1];
          var shapes2 = bodyDefs[bodyId2];

          if (doShapesCollide(shapes1, pos1, shapes2, pos2)) {
            entity1.addComponent(new Collision());
            entity2.addComponent(new Collision());
            entity1.changedInWorld();
            entity2.changedInWorld();
          }
        }
      }
    }
  }

  bool doShapesCollide(List<Polygon> shapes1, Vector2 pos1, List<Polygon> shapes2, Vector2 pos2) {
    bool shapeCollides = true;
    shapes2.forEach((shape2) {
      shapeCollides = false;
      shapes1.where((_) => !shapeCollides).forEach((shape1) {
        shapeCollides = true;
        var currentVertex1 = shape1.vertices.last;

        shape1.vertices.forEach((vertex1) {
          var normal = getNormal(currentVertex1 + pos1, vertex1 + pos1);

          double min1 = (vertex1 + pos1).dot(normal);
          double max1 = min1;
          shape1.vertices.sublist(1).forEach((projectedVertex1) {
            var dot = (projectedVertex1 + pos1).dot(normal);
            min1 = min(min1, dot);
            max1 = max(max1, dot);
          });

          double min2;
          double max2;
          bool collides = true;
          shape2.vertices.forEach((projectedVertex2) {
            var dot = (projectedVertex2 + pos2).dot(normal);
            if (null == min2) {
              min2 = dot;
              max2 = dot;
            }
            min2 = min(min2, dot);
            max2 = max(max2, dot);
          });
          if (max1 < min2 || min1 > max2) {
            shapeCollides = false;
            return;
          }
          currentVertex1 = vertex1;
        });
        if (shapeCollides) {
          return;
        }
      });
      if (shapeCollides) {
        return;
      }
    });
    return shapeCollides;
  }

  Vector2 getNormal(Vector2 vertext1, Vector2 vertex2) {
    var normal = new Vector2(- vertext1.y + vertex2.y, vertext1.x - vertex2.x);
    normal.normalize();
    return normal;
  }

  bool checkProcessing() => true;
}

class DestroyOnCollisionSystem extends EntityProcessingSystem {
  DestroyOnCollisionSystem() : super(Aspect.getAspectForAllOf([Collision, DestroyOnCollision]));

  void processEntity(Entity entity) {
    entity.deleteFromWorld();
  }
}