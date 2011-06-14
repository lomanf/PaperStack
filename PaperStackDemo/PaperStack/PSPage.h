#import <Foundation/Foundation.h>

#import "ESCommon.h"

@protocol PSPageDelegate <NSObject>

- (void)pageDidFinishDeformWithAngle:(CGFloat)angle andTime:(CGFloat)time point:(CGPoint)point theta:(CGFloat)theta;

@end


@interface PSPage : NSObject
{
  CGFloat width;    // Width of the page (x axis)                   }
  CGFloat height;   // Height of the page (y axis)                  }--- Must call -createMesh if any of these properties change.
  u_short  columns;  // Number of mesh subdivisions along the x axis }
  u_short  rows;     // Number of mesh subdivisions along the y axis }

  CGFloat rho;      // Rotation of the page around the spine of the book (y axis).
    
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
@property (nonatomic) CGPoint SP;
@property (nonatomic) CGPoint P;
@property (nonatomic, assign) id<PSPageDelegate> delegate;

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

- (CGPathRef)curlPath;
- (CGPathRef)shadowPath;
- (CGPathRef)shadowPathReverse;


@end
