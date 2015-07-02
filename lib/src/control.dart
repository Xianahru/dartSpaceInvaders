part of SpaceInvader;

const shipMovement = const Duration(milliseconds: 1000);
const projectileMovement = const Duration(milliseconds: 100);
const shootingFrequency = const Duration(milliseconds: 500);

class SpaceInvaderControl {
  
  SpaceInvaderView view = new SpaceInvaderView();
  SpaceInvaderModel model = new SpaceInvaderModel();
  
  Timer shipTrigger;
  Timer projectileTrigger;
  Timer shootingTrigger;
  
  SpaceInvaderControl() {
   
    view.start.onClick.listen((html.MouseEvent event) async {
      if(shipTrigger != null) {shipTrigger.cancel();}
      if(projectileTrigger != null) {projectileTrigger.cancel();}
      if(shootingTrigger != null) {shootingTrigger.cancel();}
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
      shootingTrigger = new Timer.periodic(shootingFrequency, (Timer t) {
        model.enemyShoot();
        view.update(model);
      });
    });
    
    view.help.onClick.listen((html.MouseEvent event) {
      view.showInstructions();
    });
    
    view.next.onClick.listen((html.MouseEvent event) {
      model.setLevel(model.getLevel()+1);
      model.loadLevel(model.getLevel());
      view.hideOverlay();
      view.update(model);
    });
    
    html.window.onKeyDown.listen((html.KeyboardEvent event) {
      if(!model.isRunning() || model.getGameOver() || model.stageClear()) return;
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