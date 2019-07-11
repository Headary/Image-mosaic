PImage main;     // Original image 
PImage smaller;  // Resized image
Icon[] allIcons; // All icons inside an array 

int scl = 2;        // How many time will be original image smaller for recreation, 1 for original size
int imgFactor = 8;  // How many time will be final image bigger than original image
int w, h; 
//If you want the best options posible, use scl=1 and imgFactor=32
//But carefully, it would result in 28,800x18,816 image
//Alternatively you can use scl=2 and imgFactor=16

PrintWriter txtoutput;
void setup () {
  size(50, 50);
  main = loadImage("composition.jpg"); //load original
  surface.setSize(main.width*imgFactor, main.height*imgFactor); //rescale window for image

  // Setup a document for writing down item counts, uncomment if you want 
  // txtoutput = createWriter("data.txt");
  
  //Load files into the array
  File[] files = listFiles(sketchPath("icons"));
  allIcons = new Icon[files.length];
  
  //Calculate average red, green and blue value for each icon
  for (int i=0; i<allIcons.length; i++) {
    String filename = files[i].toString();
    allIcons[i] = new Icon();
    allIcons[i].icon = loadImage(filename);
    allIcons[i].filename = filename;

    float avgr=0, avgg=0, avgb=0;
    for (int j=0; j<allIcons[i].icon.pixels.length; j++) {
        avgr += red(allIcons[i].icon.pixels[j]);
        avgg += green(allIcons[i].icon.pixels[j]);
        avgb += blue(allIcons[i].icon.pixels[j]);
    }
    allIcons[i].r = avgr / allIcons[i].icon.pixels.length;
    allIcons[i].g = avgg / allIcons[i].icon.pixels.length;
    allIcons[i].b = avgb / allIcons[i].icon.pixels.length;
  }
  
  //Downscale original image
  w = main.width/scl; 
  h = main.height/scl;
  smaller = createImage(w, h, RGB);
  smaller.copy(main, 0, 0, main.width, main.height, 0, 0, w, h);
}

void draw () {
  background(0);
  for (int x=0; x<smaller.width; x++) {
    for (int y=0; y<smaller.height; y++) {
      int index = x + y * w;
      PImage tile = findNearest(smaller.pixels[index]);
      image(tile, x*scl*imgFactor, y*scl*imgFactor, scl*imgFactor, scl*imgFactor);
    }
  }
  
  //Writes out how many times was every icon used, uncomment if you want.
  //writeOutput();
  
  saveFrame("exp-2-8.png"); //Save final image
  noLoop();                 //Do not loop this method
  exit();                   //Exit program
}

//Class containing each icon
class Icon {
  PImage icon;
  String filename;
  int count = 0;
  float r, g, b;
}

//Load all files inside directory
File [] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    return null;
  }
}

//Find icon with closest rgb values
PImage findNearest (color c) {
  float record = 256*256*256;
  int bestIndex = 0;
  for (int i=0; i<allIcons.length; i++) {
    float r = allIcons[i].r;
    float g = allIcons[i].g;
    float b = allIcons[i].b;
    float dist = (red(c)-r)*(red(c)-r) + (green(c)-g)*(green(c)-g) + (blue(c)-b)*(blue(c)-b);
    if (dist < record) {
      record = dist;
      bestIndex = i;
    }
  }
  allIcons[bestIndex].count++;
  return allIcons[bestIndex].icon;
}

//Output count of icons
void writeOutput() {
    for(int i=0;i<allIcons.length;i++){
    txtoutput.println(allIcons[i].filename + " : " + allIcons[i].count);
  }
  txtoutput.println("Total icon count: " + allIcons.length);
  txtoutput.flush();
  txtoutput.close();
}
