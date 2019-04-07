/*
 * FRAGMENTS_AND_FORMS
 +2019
 * designed to sample each LED's color from some point on the canvas.
 *Based in the code of :
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */

import java.net.*;
import java.util.Arrays;

public class PixelMapping 
{
  Thread thread;
  Socket socket;
  OutputStream output, pending;
  String host;
  int port;

  int[] pixelLocations ;
  int[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  PixelMapping(PApplet parent)
  {
    this.enableShowLocations = true;
    parent.registerMethod("draw", this);
  }

  // Set the location of a single LED
  void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
     
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  
  }
  
  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0) * spacing * c + 0.5),
        (int)(y + (i - (count-1)/2.0) * spacing * s + 0.5));
    }
  }

  // Set the locations of a ring of LEDs. The center of the ring is at (x, y),
  // with "radius" pixels between the center and each LED. The first LED is at
  // the indicated angle, in radians, measured clockwise from +X.
  void ledRing(int index, int count, float x, float y, float radius, float angle)
  {
    for (int i = 0; i < count; i++) {
      float a = angle + i * 2 * PI / count;
      led(index + i, (int)(x - radius * cos(a) + 0.5),
        (int)(y - radius * sin(a) + 0.5));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  void ledGrid(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag,
               boolean flip)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength,
        x + (i - (numStrips-1)/2.0) * stripSpacing * c,
        y + (i - (numStrips-1)/2.0) * stripSpacing * s, ledSpacing,
        angle, zigzag && ((i % 2) == 1) != flip);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag,
                  boolean flip)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag, flip);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
  
  }
  
  void SetData(){
     packetData = new int[3];
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
   
  }



  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  void draw()
  {
    
    if (pixelLocations == null) {
      //pixelLocations = new int[3];
      return;
    }
    
    //if (output == null) {
    //  return;
    //}

    int numPixels = pixelLocations.length;
    setPixelCount(numPixels);
    int ledAddress = 0;
    
   
    
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];
      
    
        
      packetData[ledAddress] = pixel >> 16 & 0xFF;
      packetData[ledAddress + 1] = pixel >> 8 & 0xFF;
      packetData[ledAddress + 2] = pixel & 0xFF;
      ledAddress += 3;
      if (enableShowLocations) {
        color white = color(255, 255,255);
        pixels[pixelLocation] = white;
      }
     
    }

 

    if (enableShowLocations) {
      updatePixels();
    }
    // println(packetData[ledAddress]);
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen =  numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new int[packetLen];
    }
  }
  

  
  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  color getPixel(int number)
  {
    int offset = number *3;
    if (packetData == null || packetData.length < offset + 3) {
       println("empty");
      return 0;
    }
    int r = packetData[offset];
    int g = packetData[offset+1] ;
    int b = packetData[offset+2];
    color c1 = color(r, g, b);
    return c1;
 
  }


  
}
