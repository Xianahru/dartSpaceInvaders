part of SpaceInvader;

class SpaceInvaderView {
  
  final menu = html.querySelector('#menu');
  final start = html.querySelector('#start');
  final back = html.querySelector('#back');
  final help = html.querySelector('#help');
  final next = html.querySelector('#next');
  final bars = html.querySelector('#bars');
  final levelbar = html.querySelector('#levelbar');
  final enemybar = html.querySelector('#enemybar');
  final notification = html.querySelector('#notification');
  final gamesection = html.querySelector('#gamesection');
  final board = html.querySelector('#board');
  final overlay = html.querySelector('#overlay');
  final instructions = html.querySelector('#instructions');
  final status = html.querySelector('#status');
  final healthpoints = html.querySelector('#healthpoints');
  final health = html.querySelectorAll('#health');
  final score = html.querySelector('#score');
  
  /**
   * Aktualisiert das HUD, sowie das Spielfeld
   */
  void update(SpaceInvaderModel model) {
    
    if(model.isRunning() == true) {
      menu.style.display = 'none';
      bars.style.display = 'block';
      gamesection.style.display = 'block';
      status.style.display = 'block';
    }
    
    if(model.gameOver() == true) {
      notification.style.display = 'block';
      if(model.getPlayerHitpoints() <= 0) {
        notification.innerHtml = "Game Over! Enemies destroyed your ship! </br> You reached Level ${model.getLevel()} with a score of ${model.getScore()}.";
      } else {
        notification.innerHtml = "Game Over! Enemies took over your ship! </br> You reached Level ${model.getLevel()} with a score of ${model.getScore()}.";        
      }
    }
    
    if(model.stageClear() == true) {
      showOverlay();
    }
    
    levelbar.innerHtml = "Level ${model.getLevel()}";
    enemybar.innerHtml = "${model.getLeftShips()} enemies left";
    score.innerHtml = "Points: ${model.getScore()}";
    buildHealth(model.getPlayerHitpoints());
    
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
          var tmp = field[row][col].split("_");
          switch(tmp[0]) {
            case 'player':
              point.classes.add('player');
              break;
            case 'part':
              point.classes.add(checkStatus(tmp[1]));
              break;
            case 'enemyProjectile':
              point.classes.add('enemyProjectile');
              break;
            case 'playerProjectile':
              point.classes.add('playerProjectile');
              break;
            case 'cannonPlayer':
              point.classes.add('cannonPlayer');
              break;
            case 'cannonEnemy':
              point.classes.add('cannonEnemy');
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
  
  /**
   * Erzeugt die Lebenselemente in der Healthbar
   */
  void buildHealth(int life) {
    String out = "";
    out += "<tr>";
    out += "<td>HP:</td>";
    String color = checkForColor(life);
    for(int i = 0; i < life; i++) {
      out += "<td id='health' class='$color'></td>";
    }
    for(int j = life; j < 5; j++) {
      out += "<td id='clear'></td>";
    }
    out += "</tr>";
    healthpoints.innerHtml = out;
  }
  
  /**
   * Aktualisiert die Farbe der Lebenselemente
   */
  String checkForColor(int life) {
    var color = "";
    switch(life) {
      case 1:
        color = "red";
        break;
      case 2:
        color = "yellow";
        break;
      case 3:
        color = "yellow";
        break;
      default:
        color = "green";
        break;
    }
    return color;
  }
  
  /**
   * Zeigt das how-to-play
   */
  void showInstructions() {
    menu.style.display = 'none';
    instructions.style.display = 'block';
  }
  
  /**
   * Zeigt das menü
   */
  void hideInstructions() {
    menu.style.display = 'block';
    instructions.style.display = 'none';
  }
  
  /**
   * Zeigt das Overlay
   */
  void showOverlay() {
    overlay.style.display = 'block';
  }
  
  /**
   * Versteckt das Overlay
   */
  void hideOverlay() {
      overlay.style.display = 'none';
  }
  
  /**
   * Aktualisiert den Schiffstatus der Gegner
   */
  String checkStatus(String hp) {
    String out = "";
    int tmp = int.parse(hp);
    if(tmp >= 75) {
          out = "part_75";
    } else {
      if(tmp >= 50) {
            out = "part_50";
      } else {
        if(tmp >= 25) {
              out = "part_25";
        } else {
          if(tmp >= 0) {
            out = "part_0";
          } 
        }
      }
    }
    return out;
  }
}