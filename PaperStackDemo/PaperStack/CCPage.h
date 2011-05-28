//
//  CCPage.h
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright 2010 lunaray. All rights reserved.
//
//  Based on "Deforming Pages of 3D Electronic Books" by Lichan Hong, Stuart K. Card, and Jindong (JD) Chen
//  of Palo Alto Research Center:
//  http://www2.parc.com/istl/groups/uir/publications/items/UIR-2004-10-Hong-DeformingPages.pdf
//
//  Portions borrowed and slightly modified from Jeff LaMarche, (C) 2009.
//
//  We model our page as a single vertex array indexed by two distinct triangle arrays with alternate windings
//  to represent the front and back faces. This allows us to use two different textures for each side of the page,
//  making things easier and offering maximum image fidelity. Were we to model the page as a single solid object
//  we'd have to use one texture for both the front and back sides, requiring an inefficient, awkwardly squished texture.
//
//  TODO: Calculate surface normals so we can enable proper lighting.
//        Add finger-tracking method, i.e., calculate values of rho, theta, and A for arbitraty coordinate (x, y).
//        Use blocks to optimize code where appropriate.
//
//  History:
//  20100514-wdn: Various bug fixes.
//  20100505-wdn: Initial version for public release at http://wdnuon.blogspot.com/2010/05/implementing-ibooks-page-curling-using.html


#import <Foundation/Foundation.h>

#import "CCCommon.h"

@interface CCPage : NSObject
{
  CGFloat width;    // Width of the page (x axis)                   }
  CGFloat height;   // Height of the page (y axis)                  }--- Must call -createMesh if any of these properties change.
  u_short  columns;  // Number of mesh subdivisions along the x axis }
  u_short  rows;     // Number of mesh subdivisions along the y axis }

  CGFloat rho;      // Rotation of the page around the spine of the book (y axis).
  CGFloat theta;    // Angle of the cone modeling the page curl deformation. Valid range of {0...π/2}.
                    // Very small values close to zero may give weird but interesting results such as a scroll effect.
                    // Smaller values produce a pronounced curling effect across the width of the page.
                    // A value of π/2 (90˚) results in a perfectly flat page.
    
  u_short  currentFrame;   // The current frame in the animation sequence. Range of {0...framesPerCycle}.
  u_short  framesPerCycle; // Total number of frames in one complete animation sequence (one page flip).
  
@private
  Vertex2f  *inputMesh_;
  Vertex3f  *outputMesh_;    // Vertex array for the page (front and back combined) after being deformed by rho, theta, and A deformation parameters.
  Vertex2f  *textureArray_;
  u_short    numVertices_;   // For large, complex meshes where the vertex count exceeds the max range of u_short (65535),
                            // replace with unsigned longs where needed. For most purposes unsigned shorts should suffice and conserve memory.
  Vertex3f  *triangles_;
  u_short   *faces_;          // Triangle index array that includes data for both the front and back sides.
  u_short    numFaces_;
  u_short    *frontStrip_;   // Index triangle strip for the front side.
  u_short    *backStrip_;    // Index triangle strip for the back side.
  u_short    stripLength_;
}

@property (nonatomic) CGFloat width;  // We use standard data types to decouple our model class from the implementation details of its view.
@property (nonatomic) CGFloat height;
@property (nonatomic) u_short columns;
@property (nonatomic) u_short rows;
@property (nonatomic) u_short currentFrame;
@property (nonatomic) u_short framesPerCycle;
@property (nonatomic) CGFloat rho;
@property (nonatomic) CGFloat theta;
@property (nonatomic) CGFloat Ax;
@property (nonatomic) CGFloat Ay;

- (const Vertex2f *) textureArray;
- (const Vertex3f *) vertices;  // Deformed page mesh as a vertex array.
- (const u_short *) frontFaces;  // Triangle array tesselated from vertices in counter-clockwise order to represent the front face.
- (const u_short *) backFaces;   // Triangle array tesselated from vertices in clockwise order to represent the back face.
- (u_short) numFaces;
- (const u_short *) frontStrip;
- (const u_short *) backStrip;
- (u_short) stripLength;
- (void) createMesh;
- (void) updateTextureCoord:(CGRect)rect;
- (void) incrementTime;
- (CGFloat) currentTime;
- (void) deformForTime:(CGFloat)t;  // t from {0...1}
- (void) deform;


@end
