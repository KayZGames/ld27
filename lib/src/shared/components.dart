part of shared;

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
  String bodyId;
  BodyDef(this.bodyId);
}