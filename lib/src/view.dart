part of SpaceInvader;

class SpaceInvaderView {
  
  final menu = html.querySelector('#menu');
  final start = html.querySelector('#start');
  final options = html.querySelector('#options');
  final help = html.querySelector('#help');
  final bars = html.querySelector('#bars');
  final levelbar = html.querySelector('#levelbar');
  final enemybar = html.querySelector('#enemybar');
  final notification = html.querySelector('#notification');
  final gamesection = html.querySelector('#gamesection');
  final board = html.querySelector('#board');
  
  /**
   * Aktualisiert das HUD, sowie das Spielfeld
   */
  void update(SpaceInvaderModel model) {
    
    if(model.isRunning() == true) {
      menu.style.display = 'none';
      bars.style.display = 'block';
      gamesection.style.display = 'block';
    }
    
    if(model.getGameOver() == true) {
      notification.style.display = 'block';
      notification.innerHtml = "Game Over! Enemies took over your ship!";
    }
    
    levelbar.innerHtml = "Level ${model.getLevel()}";
    enemybar.innerHtml = "${model.getLeftShips()} enemies left";
    
    updateField(model);
  }
  
  /**
   * Aktualisiert das Spielfeld durch den aktuellen Zustand eines [Models]
   */
  void updateField(SpaceInvaderModel model) {
    final field = model.getCurrentState();
    for(int row = 0; row < field.length; row++) {
      for(int col = 0; col < field[row].length; col++) {
        final point = board.querySelector('#field_${row}_${col}');
        if(point != null) {
          point.classes.clear();
          var tmp = field[row][col];
          switch(tmp) {
            case 'player':
              point.classes.add('player');
              break;
            case 'part':
              point.classes.add('part');
              break;
            case 'projectile':
              point.classes.add('projectile');
              break;
            case 'cannon':
              point.classes.add('cannon');
              break;
            default:
              point.classes.add('empty');
              break;
          }
        }
      }
    }
  }

  /**
   * Erzeugt ein Spielfeld aus dem aktuellen Zustand eines [Models]
   */
  void generateField(SpaceInvaderModel model) {
    final field = model.getCurrentState();
    String table = "";
    for(int row = 0; row < field.length; row++) {
      table += "<tr>";
        for(int col = 0; col < field[row].length; col++) {
          String assignment = field[row][col];
          final pos = "field_${row}_${col}";
          table += "<td id='$pos' class='$assignment'></td>";
        }
      table += "</tr>";
    }
    board.innerHtml = table;
  }
}