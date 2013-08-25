part of client;

class EntityRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<BodyDef> bm;
  CanvasRenderingContext2D context;
  LayeredSpriteSheet sheet;

  EntityRenderingSystem(this.context, this.sheet) : super(Aspect.getAspectForAllOf([Transform, BodyDef]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    bm = new ComponentMapper<BodyDef>(BodyDef, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var b = bm.get(entity);

    var pos = t.position;
    var spriteId = '${b.bodyId}.png';
    var layer = sheet.getLayerFor(spriteId);
    var sprite = layer.sprites['${b.bodyId}.png'];

    context.drawImageToRect(layer.image, new Rect(pos.x + sprite.dst.left, pos.y + sprite.dst.top, sprite.dst.width, sprite.dst.height), sourceRect: sprite.src);
  }
}

class DebugBodyDefRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<BodyDef> bm;
  CanvasRenderingContext2D context;
  Map<String, List<Polygon>> bodyDefs;

  DebugBodyDefRenderingSystem(this.context, this.bodyDefs) : super(Aspect.getAspectForAllOf([Transform, BodyDef]).exclude([Effect]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    bm = new ComponentMapper<BodyDef>(BodyDef, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var b = bm.get(entity);

    var pos = t.position;

    bodyDefs[b.bodyId].forEach((Polygon polygon) {
      context.beginPath();
      context.moveTo(pos.x + polygon.vertices.last.x, pos.y + polygon.vertices.last.y);
      polygon.vertices.forEach((vertex) {
        context.lineTo(pos.x + vertex.x, pos.y + vertex.y);
      });
      context.stroke();
    });
  }
}

class BackgroundRenderingSystem extends VoidEntitySystem {
  CanvasElement bgLayer;
  CanvasRenderingContext2D context;
  LayeredSpriteSheet sheet;
  BackgroundRenderingSystem(this.context, this.sheet);

  void initialize() {
    bgLayer = new CanvasElement(width: MAX_WIDTH, height: MAX_HEIGHT);
    prepareBackground(16);
  }

  void begin() {
    context.save();
  }
  void processSystem() {
    context.drawImage(bgLayer, 0, (world.time/20) % MAX_HEIGHT);
    context.drawImage(bgLayer, 0, (world.time/20) % MAX_HEIGHT - MAX_HEIGHT + 1);
  }
  void end() {
    context.restore();
  }

  void prepareBackground(int bgCount) {
    var bgContext = bgLayer.context2D;
    bgContext.clearRect(0, 0, MAX_WIDTH, MAX_HEIGHT);
    SpriteSheet layer = sheet.getLayerFor('bg_rect_0.png');
    for (int y = 0; y < MAX_HEIGHT / 16; y++) {
      for (int x = 0; x < MAX_WIDTH / 16; x++) {
        bgContext.drawImageToRect(layer.image, new Rect(x * 16, y * 16, 16, 16), sourceRect: layer.sprites['bg_rect_${random.nextInt(bgCount)}.png'].src);
      }
    }
  }
}