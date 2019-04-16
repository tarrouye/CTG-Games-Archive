float rows = 10.0;
PVector tileSize;

boolean[][] ladders;

int EASYMODE = 1;
int HARDMODE = 2;
int MODE = EASYMODE;

int score = 0;
int highscore = 0;
int hardhighscore = 0;
PVector guy = new PVector(0, 6);

float timer = 0;
float timerLength = 5;
float timerStart = 0;

boolean lost = false;
boolean menu = true;

boolean scrolling = false;
float scroll = 0;
float scrollTime = 0.125;
float scrollStart = 0;

PImage ladder;
PImage hole;
PImage[][] players;
PImage player;
PVector cPlayer;

String leaderboardID = "ladderman_score";
String hardleaderboardID = "ladderman_hard_score";

void setup() {
    float winwid = window.innerWidth / 2;
    float winhei = window.innerHeight * 0.8;
    float winsiz = min(winwid, winhei);
    size(winsiz * (5/8), winsiz);
    
    rectMode(CENTER, CENTER);
    textAlign(CENTER, CENTER);
    imageMode(CENTER);
    
    ladder = loadImage("http://i.imgur.com/xIqzbtJ.png", "png");
    hole = loadImage("http://i.imgur.com/o3a08eD.png", "png");
    stone = loadImage("http://i.imgur.com/5dnSgbO.png", "png");
    
    players = { { loadImage("http://i.imgur.com/lZBuLGQ.png", "png"), loadImage("http://i.imgur.com/eSj4r9g.png", "png") },
                { loadImage("http://i.imgur.com/api8OpI.png", "png"), loadImage("http://i.imgur.com/86vF38r.png", "png") },
                { loadImage("http://i.imgur.com/ZqLSUj2.png", "png"), loadImage("http://i.imgur.com/gfKRLMi.png", "png") },
                { loadImage("http://i.imgur.com/x2vI7Gk.png", "png"), loadImage("http://i.imgur.com/U7860TA.png", "png") },
                { loadImage("http://i.imgur.com/LQndLGf.png", "png"), loadImage("http://i.imgur.com/kfE2Yal.png", "png") } };
    
    tileSize = new PVector(width / 4, height / rows);
    
    ladders = new boolean[2][rows + 1];

    if (localStorage.getItem("lHighscore")) {
        highscore = localStorage.getItem("lHighscore");
    }
    if (localStorage.getItem("lHardHighscore")) {
        hardhighscore = localStorage.getItem("lHardHighscore");
    }

    //leaderboardSetup();
    
    reset();
}

// All highscore / leaderboard stuff

void leaderboardSetup() {
    displayLeaderboard(leaderboardID);

    dealWithUser();

    updateHighscores();
}

void dealWithUser() {
    if (localStorage.getItem("userID")) {
        //username = localStorage.getItem("username");
        userID = localStorage.getItem("userID");
    } else {
        localStorage.removeItem("userServerConfirmed");
        if (!setNewName()) {
            return null;
        }
    }

    if (!localStorage.getItem("userPass")) {
        if (!setNewPass()) {
            logOut(true);
            return null;
        }
    }
    
    if (!localStorage.getItem("userServerConfirmed")) {
        String[] serverCheck = checkUser(username, localStorage.getItem("userPass"));
        if (serverCheck[0] == "confirmed") {
            localStorage.setItem("userID", serverCheck[1]);
            userID = localStorage.getItem("userID");
            localStorage.removeItem("username");
            uploadScore(userID, highscore, leaderboardID);
            localStorage.setItem("userServerConfirmed", true);
            alert("Successfully authorized user.");
        } else {
            alert(serverCheck[1]);
            logOut();
        }
    } else {
        loadNameWithID();
    }
}

void loadNameWithID() {
    String[] serverResponse = retrieveName(userID);

    if (serverResponse[0] == "confirmed") {
        username = serverResponse[1];
    } else if (serverResponse[0] == "deleted") {
        logOut();
    }
}

void logOut(boolean dontRetry) {
    username = '';
    localStorage.removeItem("userID");
    localStorage.removeItem("userPass");
    localStorage.removeItem("userServerConfirmed");
    localStorage.removeItem("lHighscore");
    localStorage.removeItem("lHardHighscore");
    highscore = 0;
    hardhighscore = 0;

    if (dontRetry != true) {
        dealWithUser();
    }
}

void updateHighscores() {
    if (userID) {
        setHighscore(retrieveScore(userID, leaderboardID), true, EASYMODE);
        setHighscore(retrieveScore(userID, hardleaderboardID), true, HARDMODE);
    }
}

void setNewName(boolean cb) {
    String message = "Please select a username.";
    String name = prompt(message, "");

    if (name == null || name == '') {
        return false;
    } else {
        if (!cb) {
            storeNewName(name);
        } else {
            updateName(userID, name);
        }
        return true;
    }
}

void setNewPass(boolean repeat) {
    String message = "Please set a password, or enter your existing password if you've already created an account with this username.";
    if (repeat) {
         message = "Your password cannot be blank.";
    }
    String pass = prompt(message, "");

    if (pass == null) {
        return false;
    } else if (pass == '') {
        setNewPass(true);
    } else {
        localStorage.setItem("userPass", hex_md5(pass));
        return true;
    }
}

void storeNewName(String name) {
    //localStorage.setItem("username", name);
    username = name;
    refreshLeaderboard();
}

void setHighscore(int score, boolean no_upload, int mode) {
    if (mode == EASYMODE) {
        highscore = score;
        localStorage.setItem("lHighscore", highscore);
        if (no_upload != true) {
            uploadScore(userID, score, leaderboardID);
        }
    } else {
        hardhighscore = score;
        localStorage.setItem("lHardHighscore", hardhighscore);
        if (no_upload != true) {
            uploadScore(userID, score, hardleaderboardID);
        }
    }
}

// </end> All highscore shit

void reset() {
    cPlayer = new PVector((int) random(0, players.length), 1);
    animateGuy();

    for (int i = ladders[0].length - 1; i >= 0; i--) {
        generateRow(i);
    }
    guy.x = 0;
    if (!ladders[0][guy.y]) {
        guy.x = 1;
    }
    
    timerLength = 5;
    
    score = 0;
    lost = false;
    menu = true;
}

void resetTimer() {
    timerStart = millis();
    timer = timerLength;
}

void selectMode(int m) {
    MODE = m;
    menu = false;
    resetTimer();

    if (MODE == EASYMODE) {
        displayLeaderboard(leaderboardID);
    } else {
        displayLeaderboard(hardleaderboardID);
    }
}

void updateTimer() {
    if (menu) {
        return;
    }

    timer = 1 - ((millis() - timerStart) / (timerLength * 1000));
    
    if (timer < 0) {
        lose();
    }
}

void addToTimer() {
    if (MODE == EASYMODE) {
        timerStart = Math.min(millis(), timerStart + Math.max((timerLength * 100), 250));
    } else {
        timerStart = Math.min(millis(), timerStart + Math.max((timerLength * 100), 200));
    }
}

void levelUp() {
    if (MODE == EASYMODE) {
        timerLength = Math.max(timerLength * 0.75, 0.5);
    } else {
        timerLength = Math.max(timerLength * 0.75, 0.35);
    }
}

void lose() {
    lost = true;
    if (score > thismodeHigh()) {
        setHighscore(score, true, MODE);
    }
}

int thismodeHigh() {
    if (MODE == HARDMODE) {
        return hardhighscore;
    }

    return highscore;
}

void generateRow(int r) {
    ladders[0][r] = true;
    ladders[1][r] = true;
    
    int rand = (int) random(0, 3);
    if (rand != 2 && ladders[(rand + 1)%2][r + 1]) {
        ladders[rand][r] = false;
    }
}

void moveToLadder(int c) {
    if (!lost) {
        guy.x = c;
        
        if (ladders[guy.x][guy.y - 1]) {
            score += 1;
            addToTimer();
            
            if (score % 10 == 0) {
                levelUp();
            }
        } else {
            lose();
        }
        
        animateGuy();
        scrollLadder();
    }
}

void animateGuy() {
    cPlayer.y = (cPlayer.y + 1) % players[cPlayer.x].length;
    player = players[cPlayer.x][cPlayer.y];
}

void scrollLadder() {
    if (scrolling) {
        finishScroll();
    }   

    scrollStart = millis();
    scrolling = true;
}

void updateScroll() {
    if (scrolling) {
        scroll = ((millis() - scrollStart) / (scrollTime * 1000));

        if (scroll >= 1) {
             finishScroll();
        }
    }
}

void finishScroll() {
    shiftLadders();
    scroll = 0;
    scrolling = false;
}

void shiftLadders() {
    for (int i = 0; i < ladders.length; i++) {
        for (int j = ladders[i].length - 1; j >= 1; j--) {
            ladders[i][j] = ladders[i][j - 1];
        }
    }
    
    generateRow(0);
}

void draw() {
    background(255);
    
    gameDraw();
    if (menu) {
        menuDraw();
    }
    if (lost) {
        lostDraw();
    }
}

void lostDraw() {
    fill(0); textSize(width / 8);
    text("You lost", width / 2, height / 8);

    textSize(width / 12);
    text("Highscore: " + thismodeHigh(), width / 2, height * 11/16);
    
    textSize(width / 16);
    text("Press space to reset", width / 2, height * 7/8);
}

void menuDraw() {
    fill(0); textSize(width / 8);
    text("Click to select\na game mode", width / 2, height / 8);
 
    textSize(width / 12);
    text("Easy", width / 4, height / 2);
    text("Hard", width * 3/4, height / 2);
}

void gameDraw() {
    drawStones();
    drawLadders();
    drawGuy();
    
    fill(0, 128);
    textSize(width / 2);
    text(score, width / 2, height / 2);
    
    updateTimer();
    fill(0, 255, 0, 125);
    rect(width / 2, tileSize.y / 4, width / 2, tileSize.y / 2);
    fill(0, 255, 0);
    rect(width / 2, tileSize.y / 4, Math.max(0, (width / 2) * timer), tileSize.y / 2);
}

void drawStones() {
    int size = 40;
    int y = size / 2;
    for (int r = 0; r < height / size; r++) {
        int x = size / 2;
        for (int c = 0; c < width / size; c++) {
            image(stone, x, y, size, size);
            x += size;
        }
        y += size;
    }
}

void drawLadders() {
    updateScroll();

    int x = width / 4;
    for (int i = 0; i < ladders.length; i++) {
        int y = -tileSize.y / 2 + tileSize.y * scroll;
        for (int j = 0; j < ladders[i].length; j++) {
            if (ladders[i][j] == false) {
                image(hole, x, y, tileSize.x, tileSize.y);
            } else {
                image(ladder, x, y, tileSize.x, tileSize.y);
            }

            y += tileSize.y;
        }
        
        x += width / 2;
    }
}


void drawGuy() {
    int y = -tileSize.y / 2 + tileSize.y * guy.y;
    int x = width / 4 + ((width / 2) * guy.x);
    
    fill(0, 255, 0);
    ellipse(x, y, 10, 10);
    
    int w = tileSize.x * 0.65;
    int h = player.height * (w / player.width);
    image(player, x, y, w, h);
}

void keyPressed() {
    if (menu) {
        if (key == 'a' || key == 'A' || key == 'j' || key == 'J') {
            selectMode(EASYMODE);
        } else if (key == 'd' || key == 'D' || key == 'l' || key == 'L') {
            selectMode(HARDMODE);
        }
    } else if (!lost) {
        if (key == 'a' || key == 'A' || key == 'j' || key == 'J') {
            moveToLadder(0);
        } else if (key == 'd' || key == 'D' || key == 'l' || key == 'L') {
            moveToLadder(1);
        }
    } else if (key == ' ') { 
        reset();
    }
}

void mousePressed() {
    if (lost) {
        reset();
    } else if (menu) {
        if (mouseX > width / 2) {
            selectMode(HARDMODE);
        } else {
            selectMode(EASYMODE);
        }
    } else {
        if (mouseX > width / 2) {
            moveToLadder(1);
        } else {
            moveToLadder(0);
        }
    }
}
				
