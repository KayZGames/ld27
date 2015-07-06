part of client;

class EntityRenderingSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  Mapper<BodyDef> bm;
  CanvasRenderingContext2D context;
  LayeredSpriteSheet sheet;

  EntityRenderingSystem(this.context, this.sheet)
      : super(Aspect.getAspectForAllOf([Transform, BodyDef]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
    bm = new Mapper<BodyDef>(BodyDef, world);
  }

  void processEntity(Entity entity) {
    var t = tm[entity];
    var b = bm[entity];

    var pos = t.position;
    var spriteId = '${b.bodyId}.png';
    var layer = sheet.getLayerFor(spriteId);
    var sprite = layer.sprites['${b.bodyId}.png'];

    context.drawImageToRect(layer.image, new Rectangle(pos.x + sprite.dst.left,
            pos.y + sprite.dst.top, sprite.dst.width, sprite.dst.height),
        sourceRect: sprite.src);
  }
}

class DebugBodyDefRenderingSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  Mapper<BodyDef> bm;
  CanvasRenderingContext2D context;
  Map<String, List<Polygon>> bodyDefs;

  DebugBodyDefRenderingSystem(this.context, this.bodyDefs)
      : super(Aspect.getAspectForAllOf([Transform, BodyDef]).exclude([Effect]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
    bm = new Mapper<BodyDef>(BodyDef, world);
  }

  void processEntity(Entity entity) {
    var t = tm[entity];
    var b = bm[entity];

    var pos = t.position;

    bodyDefs[b.bodyId].forEach((Polygon polygon) {
      context.beginPath();
      context.moveTo(
          pos.x + polygon.vertices.last.x, pos.y + polygon.vertices.last.y);
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
    context.drawImage(bgLayer, 0, (time / 20) % MAX_HEIGHT);
    context.drawImage(bgLayer, 0, (time / 20) % MAX_HEIGHT - MAX_HEIGHT + 1);
  }
  void end() {
    context.restore();
  }

  void prepareBackground(int bgCount) {
    var bgContext = bgLayer.context2D;
    bgContext.clearRect(0, 0, MAX_WIDTH, MAX_HEIGHT);
    SpriteSheet layer = sheet.getLayerFor('bg_rect_0.png');
    int width = layer.sprites['bg_rect_0.png'].src.width;
    int height = layer.sprites['bg_rect_0.png'].src.height;
    for (int y = 0; y < MAX_HEIGHT / height; y++) {
      for (int x = 0; x < MAX_WIDTH / width; x++) {
        bgContext.drawImageToRect(
            layer.image, new Rectangle(x * width, y * height, width, height),
            sourceRect: layer.sprites[
            'bg_rect_${random.nextInt(bgCount)}.png'].src);
      }
    }
  }
}

class AchievementRenderSystem extends EntityProcessingSystem {
  Mapper<Achievement> am;
  Mapper<ExpirationTimer> em;
  CanvasRenderingContext2D context;
  Map<String, String> achievements;
  CanvasElement _cq;
  bool active = false;
  AchievementRenderSystem(this.context)
      : super(Aspect.getAspectForAllOf([Achievement, ExpirationTimer]));

  void initialize() {
    am = new Mapper<Achievement>(Achievement, world);
    em = new Mapper<ExpirationTimer>(ExpirationTimer, world);

    _cq = new CanvasElement(width: 200, height: 200);
    _cq.context2D
      ..textBaseline = 'top'
      ..font = '16px Verdana'
      ..fillStyle = '#d3d1cc'
      ..lineWidth = 5;
  }

  void begin() {
    _cq.context2D.clearRect(0, 0, 200, 200);
  }

  void processEntity(Entity entity) {
    var a = am[entity];
    var e = em[entity];
    var bounds1 = textBoundaries(_cq.context2D, a.playtime, 180);
    var bounds2 = textBoundaries(_cq.context2D, achievements[a.id], 180);
    var totalHeight = 20 + bounds1.height + bounds2.height;

    var ratio = max(1.0, 4 * e.time / e.maxTime);
    _cq.context2D
      ..globalAlpha = ratio
      ..save()
      ..fillStyle = '#ffffff'
      ..strokeStyle = '#d3d1cc'
      ..fillRect(5, 5, 190, totalHeight)
      ..restore();
    wrappedText(_cq.context2D, a.playtime, 10, 10, 200);
    wrappedText(
        _cq.context2D, achievements[a.id], 10, bounds1.height + 10, 200);
    context.drawImage(
        _cq, 5, ease.outElastic(e.time / e.maxTime, totalHeight, -totalHeight));
  }

  activate() {
    active = true;
  }

  bool checkProcessing() => active;
}

// originally part of CanvasQuery
final Pattern _whitespacePattern = new RegExp((r'\s+'));
/**
 * Writes [text] at [x], [y] and wraps at [maxWidth].
 *
 * The [nlCallback] will be called before a line is written.
 */
void wrappedText(
    CanvasRenderingContext2D ctx, String text, int x, int y, num maxWidth) {
  var regexp = new RegExp(r"(\d+)");
  var h = int.parse(regexp.firstMatch(ctx.font).group(0)) * 2;
  var lines = getLines(ctx, text, maxWidth);

  for (var i = 0; i < lines.length; i++) {
    var oy = (y + i * h * 0.6).toInt();
    var line = lines[i];
    ctx.strokeText(line, x, oy);
    ctx.fillText(line, x, oy);
  }
}

/**
 * Returns a [Rectangle] with the size of a given [text]. If [maxWidth]
 * is given, the [text] will be wrapped.
 */
Rectangle textBoundaries(CanvasRenderingContext2D ctx, String text,
    [num maxWidth]) {
  var regexp = new RegExp(r"(\d+)");
  var h = int.parse(regexp.firstMatch(ctx.font).group(0)) * 2;
  List<String> lines = getLines(ctx, text, maxWidth);
  if (null == maxWidth) {
    maxWidth = ctx.measureText(text).width;
  }
  return new Rectangle(0, 0, maxWidth, (lines.length * h * 0.6).toInt());
}

/**
 * Splits the [text] at [maxWidth] and returns a list of lines.
 */
List<String> getLines(CanvasRenderingContext2D ctx, String text,
    [num maxWidth]) {
  var words = text.split(_whitespacePattern);

  var ox = 0;

  var lines = new List<String>.from([""]);
  var spaceWidth = ctx.measureText(" ").width;
  if (null != maxWidth) {
    maxWidth += spaceWidth;
    var line = 0;
    for (var i = 0; i < words.length; i++) {
      var word = "${words[i]} ";
      var wordWidth = ctx.measureText(word).width;

      if (ox + wordWidth > maxWidth) {
        lines.add("");
        line++;
        ox = 0;
      }
      lines[line] = "${lines[line]}$word";

      ox += wordWidth;
    }
  } else {
    lines = [text];
  }
  return lines;
}
