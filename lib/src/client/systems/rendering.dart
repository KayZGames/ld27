part of client;

class EntityRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Drawable> dm;
  CanvasRenderingContext2D context;
  SpriteSheet sheet;

  EntityRenderingSystem(this.context, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Drawable]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    dm = new ComponentMapper<Drawable>(Drawable, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var d = dm.get(entity);

    var pos = t.position;
    var sprite = sheet.sprites[d.spriteId];

    context.drawImageToRect(sheet.image, new Rect(pos.x + sprite.dst.left, pos.y + sprite.dst.top, sprite.dst.width, sprite.dst.height), sourceRect: sprite.src);
  }
}

class BackgroundRenderingSystem extends VoidEntitySystem {
  CanvasElement bgLayer;
  CanvasRenderingContext2D context;
  SpriteSheet sheet;
  BackgroundRenderingSystem(this.context, this.sheet);

  void initialize() {
    bgLayer = new CanvasElement(width: MAX_WIDTH, height: MAX_HEIGHT);
    var bgContext = bgLayer.context2D;
    for (int y = 0; y < MAX_HEIGHT / 16; y++) {
      for (int x = 0; x < MAX_WIDTH / 16; x++) {
        bgContext.drawImageToRect(sheet.image, new Rect(x * 16, y * 16, 16, 16), sourceRect: sheet.sprites['bg_rect_${random.nextInt(16)}.png'].src);
      }
    }
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
}