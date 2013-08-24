part of shared;

class Drawable extends Component {
  String spriteId;
  Drawable(this.spriteId);
}

class Gun extends Component {
  double cooldown;
  Gun(this.cooldown);
}

class Cooldown extends Component {
  double value;
  Cooldown(this.value);
}

class Velocity extends Component {
  double abs, angle;
  Velocity(this.abs, this.angle);
}

class ExpirationTimer extends Component {
  double time;
  ExpirationTimer(this.time);
}

class BodyDef extends Component {
  List<Polygon> polygons;
  BodyDef(this.polygons);
}