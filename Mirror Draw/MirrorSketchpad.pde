PVector lastPoint;
PVector currentPoint;

int dWidth;
int dHeight;
float panelItemW;
int panelW;
int panelH;
PVector panelCorner;

boolean ignoreNext = false;

boolean eraserOn = false;
String eraserStatusText = "Toggle Eraser (off)";

boolean gridOn = true;
String gridStatusText = "Toggle Grid (on)";

color[] penColors = { color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 0, 125), color(125, 0, 255), color(255, 255, 0) };
int selectedCol = 3;

int[] penSizes;
int selectedSize = 1;

float scaleO;

PGraphics drawed;

void setup() {
    float winwid = window.innerWidth * 3/4;
    size(winwid, winwid / 2);

    scaleO = winwid / 1400;
    
    //bugfix for screen being messed up
    dWidth = round(width / 2);
    //panelH = round(min(100, (height - width) / 3));
    panelH = 100 * scaleO;
    panelItemW = 80 * scaleO;
    panelW = width - dWidth;
    dHeight = round(height);
    panelCorner = new PVector(dWidth, 0);

    penSizes = { 2 * scaleO, 4 * scaleO, 8 * scaleO, 16 * scaleO, 32 * scaleO, 64 * scaleO }; // scale to fit window size
    
    frameRate(100000);
    
    clearScreen();
}

void clearScreen() {
    background(255);
    
    drawed = createGraphics(dWidth, dHeight);
    drawed.beginDraw();
    drawed.background(255);
    drawed.endDraw();
    
    cancelEraser();
    drawPanel();
}

void refreshScreenFromSaved() {
    background(255);
    
    image(drawed, 0, 0);
    
    drawPanel();
}

void saveDrawing() {
    drawed.save("Mirror Sketch.png");
}

void mouseDragged() {
    currentPoint = new PVector(mouseX, mouseY);
    
    currentPoint.x = max(penSizes[selectedSize] / 2, min(currentPoint.x, dWidth - penSizes[selectedSize] / 2));
    currentPoint.y = max(0, min(currentPoint.y, dHeight));
    
    //float distF = abs(dist(currentPoint.x, currentPoint.y, lastPoint.x, lastPoint.y));
    if (mousePressed & !ignoreNext) {  
        drawed.beginDraw();
        
        strokeWeight(penSizes[selectedSize]);
        drawed.strokeWeight(penSizes[selectedSize]);
        stroke(penColors[selectedCol]);
        drawed.stroke(penColors[selectedCol]);
        if (eraserOn) {
            stroke(255);
            drawed.stroke(255);
        }
        
        //all four corners for kinkiness
        line(currentPoint.x, currentPoint.y, lastPoint.x, lastPoint.y);
        line(dWidth - currentPoint.x, currentPoint.y, dWidth - lastPoint.x, lastPoint.y);
        line(currentPoint.x, dHeight - currentPoint.y, lastPoint.x, dHeight - lastPoint.y);
        line(dWidth - currentPoint.x, dHeight - currentPoint.y, dWidth - lastPoint.x, dHeight - lastPoint.y);
        
        drawed.line(currentPoint.x, currentPoint.y, lastPoint.x, lastPoint.y);
        drawed.line(dWidth - currentPoint.x, currentPoint.y, dWidth - lastPoint.x, lastPoint.y);
        drawed.line(currentPoint.x, dHeight - currentPoint.y, lastPoint.x, dHeight - lastPoint.y);
        drawed.line(dWidth - currentPoint.x, dHeight - currentPoint.y, dWidth - lastPoint.x, dHeight - lastPoint.y);
    
        lastPoint = currentPoint;
        
        drawed.endDraw();
    }
}

void draw() {
    //faintly draw grid line
    strokeWeight(1 * scaleO);
    stroke(0, 0, 0, 125);
    if (gridOn) {
        line(0, dHeight / 2, dWidth, dHeight / 2);
        line(dWidth / 2, 0, dWidth / 2, dHeight);
    }
    line(0, 0, 0, dHeight);
    line(dWidth, 0, dWidth, dHeight);
}

void drawPanel() {
    pushMatrix();
    translate(panelCorner.x, panelCorner.y);
  
    //panel
    fill(0, 125, 255);
    noStroke();
    rect(0, 0, panelW, panelH);
    
    fill(0);
    stroke(0);
    float fs = (panelItemW / 5);
    textSize(fs);
    stroke(0);
    strokeWeight(1 * scaleO);
    text("Clear Screen", fs, panelH / 2 + fs /2);
    line(panelW / 4, 0, panelW / 4, panelH);
    text(eraserStatusText, panelW / 4 + fs, panelH / 2 + fs / 2);
    line(panelW * 2/4, 0, panelW * 2/4, panelH);
    text(gridStatusText, panelW * 2/4 + fs, panelH / 2 + fs / 2);
    line(panelW * 3/4, 0, panelW * 3/4, panelH);
    text("Save Drawing", panelW * 3/4 + fs, panelH / 2 + fs / 2);
    
    fill(255);
    noStroke();
    rect(0, panelH, panelW, panelH * 2);
    
    //color dots
    for (int i = 0; i < penColors.length; i++) {
        strokeWeight(3 * scaleO);
        if (i == selectedCol) {
            stroke(0);
        } else {
            noStroke();
        }
        
        fill(penColors[i]);
        ellipse((panelW / (penColors.length + 1)) * (i + 1), panelH * 1.5, panelH / 2, panelH / 2);
    }
    
     //size dots
    for (int i = 0; i < penSizes.length; i++) {
        noStroke();
        
        fill(penColors[selectedCol]);
        ellipse((panelW / (penSizes.length + 1)) * (i + 1), panelH * 2.5, penSizes[i], penSizes[i]);
        
        if (i == selectedSize) {
            stroke(0);
            strokeWeight(3 * scaleO);
            noFill();
            ellipse((panelW / (penSizes.length + 1)) * (i + 1), panelH * 2.5, max(panelH / 2, penSizes[i] + 2), max(panelH / 2, penSizes[i] + 2));
        }
    }
    
    popMatrix();
}

void mousePressed() {
    lastPoint = new PVector(mouseX, mouseY);
    
    if ((mouseY >= panelCorner.y & mouseY <= panelCorner.y + panelH & mouseX >= panelCorner.x & mouseX <= panelCorner.x + panelW) || mouseX >= dWidth || mouseY >= dHeight) {
        ignoreNext = true;
    }

}
void mouseReleased() {
    if (ignoreNext) {
        //top panel buttons
        float nMX = mouseX - panelCorner.x;
        float nMY = mouseY - panelCorner.y;
        if (nMY < panelH) {
          if (nMX < panelW / 4 ) {
              clearScreen();
          }
          
          if (nMX > panelW / 4 & nMX < panelW * 2/4) {
              toggleEraser();
          }
          
          if (nMX > panelW * 2/4 & nMX < panelW * 3/4) {
              toggleGrid();
          }
          
          if (nMX > panelW * 3/4) {
              saveDrawing();
          }
        }
        
        //color picker
        if (nMY > panelH & nMY < panelH * 2) {
            for (int i = 0; i < penColors.length; i++) {
                float xP = (panelW / (penColors.length + 1)) * (i + 1);
                if (nMX >= xP - panelH/2 & nMX <= xP + panelH/2) {
                    selectedCol = i; 
                    cancelEraser();
                }
            }
        }
        
        //size picker
        if (nMY > panelH * 2 & nMY < panelH * 3) {
            for (int i = 0; i < penSizes.length; i++) {
                float xP = (panelW / (penSizes.length + 1)) * (i + 1);
                if (nMX >= xP - panelH/2 & nMX <= xP + panelH/2) {
                    selectedSize = i; 
                }
            }
        }
        
        drawPanel();
    }
    
    ignoreNext = false;
}

void toggleEraser() {
    if (eraserOn) {
        eraserOn = false;
        eraserStatusText = "Toggle Eraser (off)";
    } else {
        eraserOn = true;
        eraserStatusText = "Toggle Eraser (on)";
    }
    
    drawPanel();
}

void cancelEraser() {
    if (eraserOn) {
        toggleEraser();
    }
}

void toggleGrid() {
    if (gridOn) {
        gridOn = false;
        gridStatusText = "Toggle Grid (off)";
    } else {
        gridOn = true;
        gridStatusText = "Toggle Grid (on)";
    }
    
    refreshScreenFromSaved();
}
