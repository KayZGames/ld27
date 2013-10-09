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

    context.drawImageToRect(layer.image, new Rectangle(pos.x + sprite.dst.left, pos.y + sprite.dst.top, sprite.dst.width, sprite.dst.height), sourceRect: sprite.src);
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
    int width = layer.sprites['bg_rect_0.png'].src.width;
    int height= layer.sprites['bg_rect_0.png'].src.height;
    for (int y = 0; y < MAX_HEIGHT / height; y++) {
      for (int x = 0; x < MAX_WIDTH / width; x++) {
        bgContext.drawImageToRect(layer.image, new Rectangle(x * width, y * height, width, height), sourceRect: layer.sprites['bg_rect_${random.nextInt(bgCount)}.png'].src);
      }
    }
  }
}

class AchievementRenderSystem extends EntityProcessingSystem {
  ComponentMapper<Achievement> am;
  ComponentMapper<ExpirationTimer> em;
  CanvasRenderingContext2D context;
  Map<String, String> achievements;
  CqWrapper _cq;
  bool active = false;
  AchievementRenderSystem(this.context) : super(Aspect.getAspectForAllOf([Achievement, ExpirationTimer]));

  void initialize() {
    am = new ComponentMapper<Achievement>(Achievement, world);
    em = new ComponentMapper<ExpirationTimer>(ExpirationTimer, world);

    _cq = cq(200, 200);
    _cq.context2D..textBaseline = 'top'
                 ..font = '16px Verdana'
                 ..fillStyle = '#d3d1cc'
                 ..lineWidth = 5;
  }

  void begin() {
    _cq.clear();
  }

  void processEntity(Entity entity) {
    var a = am.get(entity);
    var e = em.get(entity);
    var bounds1 = _cq.textBoundaries(a.playtime, 180);
    var bounds2 = _cq.textBoundaries(achievements[a.id], 180);
    var totalHeight = 20 + bounds1.height + bounds2.height;

    var ratio = max(1.0, 4 * e.time / e.maxTime);
    _cq.context2D.globalAlpha = ratio;
    _cq.roundRect(5, 5, 190, totalHeight, 15, strokeStyle: '#d3d1cc', fillStyle: '#ffffff');
    _cq.wrappedText(a.playtime, 10, 10, 200);
    _cq.wrappedText(achievements[a.id], 10, bounds1.height + 10, 200);
    context.drawImage(_cq.canvas, 5, ease.outElastic(e.time / e.maxTime, totalHeight, -totalHeight));
  }

  activate() {
    active = true;
  }

  bool checkProcessing() => active;
}