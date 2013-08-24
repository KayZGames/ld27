part of client;

class BackgroundRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D context;
  BackgroundRenderingSystem(this.context);
  void begin() {
    context.save();
  }
  void processSystem() {
    context.clearRect(0, 0, MAX_WIDTH, MAX_HEIGHT);
  }
  void end() {
    context.restore();
  }
}