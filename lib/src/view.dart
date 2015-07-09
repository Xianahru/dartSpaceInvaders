part of SpaceInvader;

/**
 * Ein Objekt der [SpaceInvaderView] nutzt den DOM-Tree 
 * um dem Nutzer die Änderungen im [SpaceInvaderModel]
 * zu visualisieren
 */
class SpaceInvaderView {
  
  /**
   * Element mit der id="menu" des DOM-Trees
   */
  final menu = html.querySelector('#menu');
  /**
   * Element mit der id="start" des DOM-Trees
   */
  final start = html.querySelector('#start');
  /**
   * Element mit der id="back" des DOM-Trees
   */
  final back = html.querySelector('#back');
  /**
   * Element mit der id="help" des DOM-Trees
   */
  final help = html.querySelector('#help');
  /**
   * Element mit der id="next" des DOM-Trees
   */
  final next = html.querySelector('#next');
  /**
   * Element mit der id="bars" des DOM-Trees
   */
  final bars = html.querySelector('#bars');
  /**
   * Element mit der id="levelbar" des DOM-Trees
   */
  final levelbar = html.querySelector('#levelbar');
  /**
   * Element mit der id="enemybar" des DOM-Trees
   */
  final enemybar = html.querySelector('#enemybar');
  /**
   * Element mit der id="notification" des DOM-Trees
   */
  final notification = html.querySelector('#notification');
  /**
   * Element mit der id="gamesection" des DOM-Trees
   */
  final gamesection = html.querySelector('#gamesection');
  /**
   * Element mit der id="board" des DOM-Trees
   */
  final board = html.querySelector('#board');
  /**
   * Element mit der id="overlay" des DOM-Trees
   */
  final overlay = html.querySelector('#overlay');
  /**
   * Element mit der id="instructions" des DOM-Trees
   */
  final instructions = html.querySelector('#instructions');
  /**
   * Element mit der id="status" des DOM-Trees
   */
  final status = html.querySelector('#status');
  /**
   * Element mit der id="healthpoints" des DOM-Trees
   */
  final healthpoints = html.querySelector('#healthpoints');
  /**
   * Element mit der id="health" des DOM-Trees
   */
  final health = html.querySelectorAll('#health');
  /**
   * Element mit der id="score" des DOM-Trees
   */
  final score = html.querySelector('#score');
  
  /**
   * Nutzt ein [SpaceInvaderModel] um das Spielfeld zu aktualisieren
   */
  void update(SpaceInvaderModel model) {
    
    //Schalte View auf Spielmodus
    if(model.isRunning() == true) {
      menu.style.display = 'none';
      bars.style.display = 'block';
      gamesection.style.display = 'block';
      status.style.display = 'block';
      
      //Aktualisiere die restlichen Feinde
      if(model.getLeftShips() == 1) {
        enemybar.innerHtml = "${model.getLeftShips()} enemy left";
      } else {
        enemybar.innerHtml = "${model.getLeftShips()} enemies left";
      }
      
      //Aktualisiere Level, Score und Lebenspunkte
      levelbar.innerHtml = "Level ${model.getLevel()}";
      score.innerHtml = "Points: ${model.getScore()}";
      buildHealth(model.getPlayerHitpoints());
      
      //Update das Feld
      updateField(model);
    }
    
    //Schalte Spiel auf Game Over und zeige Game Over Message
    if(model.gameOver() == true) {
      notification.style.display = 'block';
      if(model.getPlayerHitpoints() <= 0) {
        notification.innerHtml = "Game Over! Enemies destroyed your ship! </br> You reached Level ${model.getLevel()} with a score of ${model.getScore()}.";
      } else {
        notification.innerHtml = "Game Over! Enemies took over your ship! </br> You reached Level ${model.getLevel()} with a score of ${model.getScore()}.";        
      }
    }
    
    //Blende das Overlay ein
    if(model.stageClear()) {
      if(model.getLevel()+1 > model._levels.length) {
        overlay.style.display = 'block';
        overlay.innerHtml = "Congratulations! </br> You blasted all the enemies and saved the entire galaxy!";
      } else {
        overlay.style.display = 'block';
      }
    }
  }
  
  /**
   * Aktualisiert das Spielfeld durch den aktuellen Zustand
   * eines Objektes der Klasse [SpaceInvaderModel]
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
              point.classes.add(checkStatus('part', tmp[1]));
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
              point.classes.add(checkStatus('cannonEnemy', tmp[1]));
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
   * Erzeugt ein Spielfeld aus dem aktuellen Zustand
   * eines Objektes der Klasse [SpaceInvaderModel]
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
   * Der zu übergebnde Wert, ist der akutelle [hitpoints]-Wert
   * des [PlayerShip]-Objekts
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
   * Der zu übergebnde Wert, ist der akutelle [hitpoints]-Wert
   * des [PlayerShip]-Objekts
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
   * Zeigt die Erklärung
   */
  void showInstructions() {
    menu.style.display = 'none';
    instructions.style.display = 'block';
  }
  
  /**
   * Zeigt das Menü
   */
  void hideInstructions() {
    menu.style.display = 'block';
    instructions.style.display = 'none';
  }
  
  /**
   * Visualisiert den aktuellen Gesundheitsstatus eines Schiffes
   * Der zu übergebende Wert, ist der aktuelle [hitpoints]-Wert
   * eines Objektes, der Klasse [EnemyShip]
   */
  String checkStatus(String part, String hp) {
    
    String out = "";
    int tmp = int.parse(hp);

    switch(part) {
      case 'part':
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
        break;
      case 'cannonEnemy':
        if(tmp >= 75) {
              out = "cannonEnemy_75";
        } else {
          if(tmp >= 50) {
                out = "cannonEnemy_50";
          } else {
            if(tmp >= 25) {
                  out = "cannonEnemy_25";
            } else {
              if(tmp >= 0) {
                out = "cannonEnemy_0";
              } 
            }
          }
        }
    }
    return out;
  }
}