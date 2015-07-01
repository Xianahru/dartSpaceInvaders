part of SpaceInvader;

const shipMovement = const Duration(milliseconds: 1000);
const projectileMovement = const Duration(milliseconds: 100);

class SpaceInvaderControl {
  
  SpaceInvaderView view = new SpaceInvaderView();
  SpaceInvaderModel model = new SpaceInvaderModel();
  
  Timer shipTrigger;
  Timer projectileTrigger;
  
  SpaceInvaderControl() {
   
    view.start.onClick.listen((html.MouseEvent event) async {
      if(shipTrigger != null) {shipTrigger.cancel();}
      if(projectileTrigger != null) {projectileTrigger.cancel();}
      await model.setup();
      model.loadLevel(1);
      model.setRunning(true);
      view.generateField(model);
      view.update(model);
      shipTrigger = new Timer.periodic(shipMovement, (Timer t) {
        model.moveEnemies();
        view.update(model);
        });
      projectileTrigger = new Timer.periodic(projectileMovement, (Timer t) {
        model.moveProjectiles();
        view.update(model);
      });
    });
    
    html.window.onKeyDown.listen((html.KeyboardEvent event) {
      if(model.isRunning() == false && model.getGameOver() == false) return;
      switch(event.keyCode) {
        case html.KeyCode.LEFT:
          model.movePlayer('left');
          view.update(model);
          break;
        case html.KeyCode.RIGHT:
          model.movePlayer('right');
          view.update(model);
          break;
        case html.KeyCode.SPACE:
          model.playerShoot();
          break;
      }
    });
  } 
}