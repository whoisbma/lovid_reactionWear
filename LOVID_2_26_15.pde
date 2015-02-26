import processing.video.*;

public final int movieTotal = 5; 
ArrayList<VidInstance> vidInstances = new ArrayList<VidInstance>();
Movie movies[] = new Movie[movieTotal]; 

VidInstance test; 

public int instanceCount = 1; 
boolean moviesLoaded = false; 

//play all active vidInstance clips and masks and do their countdown
//maintain global beamBroken count to know when to fade out

boolean beamBroken = false; 
int beamBrokenCount = 0;
float globalFadeRate = 0.1;
float framesBeforeInstanceDelete = 900;  //30 seconds of 30FPS


int ww;
int hh; 
int movieW = 640;
int movieH = 480; 

//replace the key press stuff for your actual beam breaking logic
void keyPressed() {
  if (key == ' ') {
    beamBroken = true;
  }
} 

boolean sketchFullScreen() {
  return true;
}

public void setup() {
  
  ww = displayWidth; 
  hh = displayHeight; 
  size(ww, hh, P2D);
  frameRate(30);
  loadMovies();
  while (moviesLoaded != true) {
  }
  vidInstances.add(new VidInstance(0, true, false));
  for (int i = 1; i < movieTotal; i++) {
    vidInstances.add(new VidInstance(i, false, false)); 
    vidInstances.get(i).invisible = true;
  }
}

public void draw() {
  background(0); 
  beamBrokenCount++; 
  //println(beamBroken); 
  //println(vidInstances.size());
  if (beamBroken == true) {
    beamBrokenCount = 0; 

    vidInstances.get(instanceCount).mask.modifyMask(random(0, 450), random(0, 350), random(50, 300), random(50, 300));
    vidInstances.get(instanceCount).invisible = false;
    vidInstances.get(instanceCount).count = 0;

    if (instanceCount < vidInstances.size()-1) {
      instanceCount++;
    } else {
      instanceCount = 1;
    }
  
    beamBroken = false;
  }

  for (VidInstance vid : vidInstances) {
    vid.update();
  }
}

public void loadMovies() {
  for (int i = 0; i < movieTotal; i++) {
    movies[i] = new Movie(this, (i+1) + ".mov");
  }
  moviesLoaded = true;
} 

public class VidInstance {
  public float a; 
  public int count; 
  public Movie clip; 
  public MaskRect mask; 
  private boolean isLoaded; 
  private String moviePath; 
  private boolean background;
  private boolean soundOn; 
  private int movieIndex; 
  private float fadeRate; 
  private boolean invisible; 

  VidInstance(int movieIndex, boolean background, boolean soundOn) {
    this.a = 255; 
    this.count = 0; 
    this.moviePath = moviePath; 
    this.background = background;
    this.soundOn = soundOn;
    this.movieIndex = movieIndex;
    this.clip = movies[movieIndex];
    this.fadeRate = globalFadeRate + random(-0.5, 0.5); 
    this.invisible = false;

    if (background == true) {
      this.mask = new MaskRect(0, 0, movieW, movieH);
    } else {
      this.mask = new MaskRect(random(0, 450), random(0, 350), random(50, 300), random(50, 300));
    }

    this.clip.loop();
    if (!soundOn) {
      this.clip.volume(0);
    }
  } 

  public void update() { 
    count++;
    if (clip != null) {
      if (clip.available()) {
        clip.read();
      }
      float alpha = a - beamBrokenCount * fadeRate;
      if (alpha < 0) {
        alpha = 0;
      }
      if (count > framesBeforeInstanceDelete && background == false) {
        invisible = true;
      } 
      
      tint(255, alpha);
      mask.applyMask(clip);
      if (invisible == false) {
        image(clip, 0, 0, ww, hh);
      }
    }
  }
} 

public class MaskRect {
  public float x;
  public float y;
  public float w;
  public float h; 
  public PImage maskImg;

  MaskRect(float x, float y, float w, float h) {
    this.x = x;
    this.y = y; 
    this.w = w;
    this.h = h; 
    maskImg = createImage(movieW, movieH, RGB); 
    for (int i = 0; i < movieW; i++) {
      for (int j = 0; j < movieH; j++) {
        if ((i > x && i < x+w) && (j > y && j < y+h)) {
          maskImg.set(i, j, color(255, 255, 255));
        } else { 
          maskImg.set(i, j, color(0, 0, 0));
        }
      }
    }
  } 

  public void modifyMask(float x, float y, float w, float h) {
    for (int i = 0; i < movieW; i++) {
      for (int j = 0; j < movieH; j++) {
        if ((i > x && i < x+w) && (j > y && j < y+h)) {
          this.maskImg.set(i, j, color(255, 255, 255));
        } else { 
          this.maskImg.set(i, j, color(0, 0, 0));
        }
      }
    }
  } 

  public void applyMask(PImage target) {
    target.mask(this.maskImg);
  }
}

