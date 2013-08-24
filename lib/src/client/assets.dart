part of client;


Future<SpriteSheet> loadSpritesheet(String path) {
  return HttpRequest.getString('$path.json')
    .then(processAssets).then((assets) => createSpriteSheet(path, assets));
}

Future<SpriteSheet> createSpriteSheet(String path, Map<String, Map<String, Map<String, dynamic>>> assets) {
  var completer = new Completer<SpriteSheet>();
  var img = new ImageElement();
  img.onLoad.listen((_) {
    var sprites = new Map<String, Sprite>();
    assets['frames'].forEach((assetName, assetData) {
      sprites[assetName] = new Sprite(assetData);
    });
    var sheet = new SpriteSheet(img, sprites);
    completer.complete(sheet);
  });
  img.src = '$path.png';
  return completer.future;
}

Future<Map<String, dynamic>> processAssets(String assetJson) {
  return new Future.value(json.parse(assetJson));
}

class SpriteSheet {
  final ImageElement image;
  final Map<String, Sprite> sprites;
  SpriteSheet(this.image, this.sprites);
}

class Sprite {
  Rect src;
  Rect dst;
  Sprite(Map<String, dynamic> singleAsset) {
    _Asset asset = new _Asset(singleAsset);
    var frame = asset.frame;
    var cx, cy;
    if (asset.trimmed) {
      cx = -(asset.sourceSize.w ~/ 2 - asset.spriteSourceSize.x);
      cy = -(asset.sourceSize.h ~/ 2 - asset.spriteSourceSize.y);
    } else {
      cx = -asset.frame.w ~/ 2;
      cy = -asset.frame.h ~/ 2;
    }

    src = new Rect(frame.x, frame.y, frame.w, frame.h);
    dst = new Rect(cx, cy, frame.w, frame.h);
  }
}

class _Asset {
  _Rect frame;
  bool trimmed;
  _Rect spriteSourceSize;
  _Size sourceSize;
  _Asset(Map<String, dynamic> asset) : frame = new _Rect(asset["frame"]),
                                      trimmed = asset["trimmed"],
                                      spriteSourceSize = new _Rect(asset["spriteSourceSize"]),
                                      sourceSize = new _Size(asset["sourceSize"]);
}

class _Rect {
  int x, y, w, h;
  _Rect(Map<String, int> rect) : x = rect["x"].toInt(),
                                y = rect["y"].toInt(),
                                w = rect["w"].toInt(),
                                h = rect["h"].toInt();
}

class _Size {
  int w, h;
  _Size(Map<String, int> rect) : w = rect["w"].toInt(),
                                h = rect["h"].toInt();
}