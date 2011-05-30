//
//  CCPage.m
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright 2010 lunaray. All rights reserved.
//


#import "CCPage.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface CCPage ()
// Empty category for "private" methods
- (void)createTriangleArray;
- (void)createTriangleStrip;
@end


@implementation CCPage

@synthesize width, height, columns, rows;
@synthesize currentFrame, framesPerCycle;
@synthesize rho, theta, Ax, Ay, P;


- (id)init
{
    self = [super init];
	if ( self )
	{
    width         = 1.0f;
    height        = 1.0f;
    columns       = 8;
    rows          = 10;
    theta         = 90.0f;
    rho           = 0.0f;
	}
	return self;
}

- (void)dealloc
{
  if (inputMesh_ != NULL)
    free(inputMesh_);
  if (outputMesh_ != NULL)
    free(outputMesh_);
  if (textureArray_ != NULL)
    free(textureArray_);
  if (triangles_ != NULL)
    free(triangles_);
  if (faces_ != NULL)
    free(faces_);
  if (frontStrip_ != NULL)
    free(frontStrip_);
  if (backStrip_ != NULL)
    free(backStrip_);
	[super dealloc];
}

- (const Vertex2f *)textureArray
{
  return textureArray_;
}

- (const Vertex3f *)vertices
{
  return outputMesh_;
}

- (const u_short *)frontFaces
{
  return faces_;
}

- (const u_short *)backFaces
{
  // Return an offset since we store both front and back triangle arrays together in one array.
  return faces_ + numFaces_ * 3;
}

- (u_short)numFaces
{
  return numFaces_;
}

- (const u_short *)frontStrip
{
  return frontStrip_;
}

- (const u_short *)backStrip
{
  return backStrip_;
}

- (u_short)stripLength
{
  return stripLength_;
}

- (void)createMesh
{
  u_short vCountX = columns + 1; // Number of vertices along the x axis
  u_short vCountY = rows + 1; // Number of vertices along the y axis
  numFaces_ = columns * rows * 2;
  
  numVertices_  = vCountX * vCountY;
  if (inputMesh_ != NULL)
    free(inputMesh_);
  inputMesh_ = malloc(sizeof(Vertex2f) * numVertices_);
  if (outputMesh_ != NULL)
    free(outputMesh_);
  outputMesh_ = malloc(sizeof(Vertex3f) * numVertices_);
  if (textureArray_ != NULL)
    free(textureArray_);
  textureArray_ = malloc(sizeof(Vertex2f) * numVertices_);
    
  u_short vi = 0;	// vertex index
  short iiX, iiY;
  CGFloat px, py;
  // Create our flat page geometry as a vertex array. Even though our page has two sides, we need to generate only one
  // set of vertices since the front and back are coplanar meshes.
  for (iiY = 0; iiY < vCountY; iiY++)
  {
    for (iiX = 0; iiX < vCountX; iiX++)
    {
      px = (CGFloat)iiX * width / columns;
      py = (CGFloat)iiY * height / rows - (height*0.5);
      inputMesh_[vi].x = px;
      inputMesh_[vi].y = py;
      textureArray_[vi].x = (CGFloat)iiX / columns;
      textureArray_[vi].y = (CGFloat)(iiY) / rows;
      vi++;
     // NSLog(@"%d: (%d, %d) = (%0.2f, %0.2f)", vi, iiX, iiY, px, py);
    }
  }

  // Once we have our basic page geometry, tesselate it into an array of discrete triangles or triangle strips.
#if USE_TRIANGLE_STRIPS
  [self createTriangleStrip];
#else
  [self createTriangleArray];
#endif
  
}

- (void) updateTextureCoord:(CGRect)rect 
{
    u_short vCountX = columns + 1; // Number of vertices along the x axis
    u_short vCountY = rows + 1; // Number of vertices along the y axis
    
    CGFloat rox = rect.origin.x;
    CGFloat roy = rect.origin.y;
    CGFloat row = rect.size.width;
    CGFloat roh = rect.size.height;
    
    if (textureArray_ != NULL)
        free(textureArray_);
    textureArray_ = malloc(sizeof(Vertex2f) * numVertices_);
    
    u_short vi = 0;	// vertex index
    short iiX, iiY;
    // Create our flat page geometry as a vertex array. Even though our page has two sides, we need to generate only one
    // set of vertices since the front and back are coplanar meshes.
    for (iiY = 0; iiY < vCountY; iiY++)
    {
        for (iiX = 0; iiX < vCountX; iiX++)
        {
            textureArray_[vi].x = rox + (CGFloat)iiX / columns * row;
            textureArray_[vi].y = roy + (CGFloat)(iiY) / rows * roh;
            vi++;
        }
    }

}

- (void)incrementTime
{
  currentFrame++;
  currentFrame %= framesPerCycle;
}

- (CGFloat)currentTime
{
  return (CGFloat)currentFrame / framesPerCycle;
}

- (void)deformForTime:(CGFloat)t
{
 
}

- (void)deform2
{
  // This method must be called after any values of rho, theta, or A have been changed in order to update the output geometry.

  // This is the guts of the conical page deformation algorithm, using just basic trigonometry.
  // Since each vertex is independent of any other, these calculations are very well suited for parallelization using
  // blocks (i.e., for GCD), vertex shaders (OpenGL ES 2.0), or other available features.
  
	Vertex2f  vi;   // Current input vertex, iterated over the flat page input mesh (basic vertex array).
  Vertex3f  v1;   // First stage of the deformation, with only theta and A applied. This results in a curl, but no rotation.
  Vertex3f *vo;   // Pointer to the finished vertex in the output mesh, after applying rho to v1 with a basic rotation transform.
  
    Ay = -0.5 + fminf( 0.0, Ay );
  // Iterate over the input mesh to deform each vertex.
	CGFloat R, r, beta, ttheta;
  for (u_short ii = 0; ii < numVertices_; ii++)
  {
      ttheta = theta;
    vi    = inputMesh_[ii];                           // Get the current input vertex from our input mesh.
//    R     = sqrt(vi.x * vi.x + pow(vi.y - A, 2.0f));  // Radius of the circle circumscribed by vertex (vi.x, vi.y) around A on the x-y plane.
    R     = sqrt(pow(vi.x - Ax, 2.0f) + pow(vi.y - Ay, 2.0f));  // Radius of the circle circumscribed by vertex (vi.x, vi.y) around A on the x-y plane.
      if ( vi.x <= Ax ) {
          ttheta = M_PI*0.5; 
      }
    r     = R * sin(ttheta);                       // From R, calculate the radius of the cone cross section intersected by our vertex in 3D space.
      
    if ( vi.x < Ax ) 
        beta = 0.0;
    else
        beta  = asin((vi.x-Ax) / R) / sin(ttheta);          // Angle SCT, the angle of the cone cross section subtended by the arc |ST|.
      
    v1.x  = r * sin(beta) + Ax;
      if (vi.x < Ax) v1.x = vi.x;
    v1.y  = R + Ay - r * (1.0f - cos(beta)) * sin(ttheta); // *** MAGIC!!! ***
      if (vi.x < Ax) v1.y = vi.y;
    v1.z  = r * (1.0f - cos(beta)) * cos(ttheta);

    // Apply a basic rotation transform around the y axis to rotate the curled page. These two steps could be combined
    // through simple substitution, but are left separate to keep the math simple for debugging and illustrative purposes.
    vo    = &outputMesh_[ii];
    vo->x = (v1.x * cos(rho) - v1.z * sin(rho));
    vo->y =  v1.y;
    vo->z = (v1.x * sin(rho) + v1.z * cos(rho));
  }  
}

- (void)deform
{    
	CGFloat RB1, RB2, b1, b2, ipo, R, Rc, beta, ttheta;

//    NSLog(@"Px: %f", P.x );
    
    P.y = P.y + 0.01;
    RB2 = ( 1 + P.y ) * 0.5;
    RB1 = 1 - RB2;
    RB1 *= ( 1.0 - fabs( P.x ) ) * 0.5;
    RB2 *= ( 1.0 - fabs( P.x ) ) * 0.5;
    
    b1 = P.x + ( RB1 * 0.5 );
    b2 = P.x + ( RB2 * 0.5 );
    ipo = sqrtf( pow( b1 - b2, 2 ) );
    theta = fminf( asinf( ipo ), M_PI * 0.48 );
    Ax = P.x * 0.5;
    Ay = fmaxf( 1 + fminf( RB1, RB2 ) * 0.5 * ( 1 / tanf( theta ) ), 1.1 ) * ( RB1 > RB2 ? 1.0 : -1.0 );
    
//    NSLog(@"RB1: %f, RB2: %f", RB1, RB2 );
//    NSLog(@"Theta: %f", theta );
//    NSLog(@"Ay: %f", Ay );
//    NSLog(@"Ax: %f", Ax );
    
    // deform mash
    
    Vertex2f  vi;
    Vertex3f  v1;
    Vertex3f *vo;
    
    for ( u_short ii = 0; ii < numVertices_; ii++ ) {
        vi = inputMesh_[ ii ];
        
        ttheta = theta;
        if ( vi.x < Ax ) {
            ttheta = M_PI * 0.5;
        }
        
        R = sqrt( pow( vi.x - Ax, 2.0f ) + pow( vi.y - Ay, 2.0f ) );
        Rc = R * sin( ttheta ); 
        beta = asin( ( vi.x - Ax ) / R ) / sin( ttheta );

        // translate vertex
        v1.x  = Rc * sin( beta ) + Ax;
        if ( RB1 < RB2 ) {
            v1.y  = R + Ay - Rc * ( 1.0f - cos( beta ) ) * sin( ttheta );
        } else {
            v1.y  = R - Ay - Rc * ( 1.0f - cos( beta ) ) * sin( ttheta );
            v1.y  = -v1.y;
        }
        v1.z  = Rc * ( 1.0f - cos( beta ) ) * cos( ttheta );
        
        // output vertex
        vo = &outputMesh_[ ii ];
        //vo->x = ( v1.x * cos( rho ) - v1.z * sin( rho ) );
        //vo->y =  v1.y;
        //vo->z = ( v1.x * sin( rho ) + v1.z * cos( rho ) );
        vo->x = v1.x;
        vo->y = v1.y;
        vo->z = v1.z;
    }
}

#pragma mark -
#pragma mark Private methods

- (void)createTriangleArray
{  
  u_short vCountX  = columns + 1; // Number of vertices along the x axis
  u_short numQuads = columns * rows;
  numFaces_ = numQuads * 2;
  if (faces_ != NULL)
    free(faces_);
  faces_ = malloc(sizeof(u_short) * numFaces_ * 6);  // Store both front and back triangle arrays in one array.
  
  u_short vi = 0;	// vertex index  
  u_short index;
  u_short rowNum, colNum;
  u_short ll, lr, ul, ur;
	for (index = 0; index < numQuads; index++)
	{	
		rowNum = index / columns;
		colNum = index % columns;
		ll = (rowNum) * vCountX + colNum;
		lr = ll + 1;
		ul = (rowNum + 1) * vCountX + colNum;
		ur = ul + 1;
    // Make two triangles out of each quad.
    // Wind the front of the page counter-clockwise so we can view it straight on.
    QuadToTrianglesWindCCWSet(&faces_[vi], ul, ur, ll, lr);
    // Wind the back of the page clockwise so it's visible only when it's been flipped.
    QuadToTrianglesWindCWSet(&faces_[vi + numFaces_ * 3], ul, ur, ll, lr);
		vi += 6;
	}
}

- (void)createTriangleStrip
{
  // Standard algorithm for tesselating a grid into an optimized triangle strip without resorting to a complex Hamiltonian algorithm.
  
  u_short vCountX = columns + 1; // Number of vertices along the x axis
  u_short vCountY = rows + 1;    // Number of vertices along the y axis
  
  stripLength_ = (vCountX * 2) * (vCountY - 1) + (vCountY - 2);
  if (frontStrip_ != NULL)
    free(frontStrip_);
  frontStrip_ = malloc(sizeof(u_short) * stripLength_);
  if (backStrip_ != NULL)
    free(backStrip_);
  backStrip_ = malloc(sizeof(u_short) * stripLength_);
  
  // Construct a triangle strip by scanning back and forth up our mesh, inserting degenerate triangles as necessary
  // to link adjacent rows.
  short iiX, iiY;
  u_short rowOffset, index = 0;
  BOOL lastRow, oddRow;
  for (iiY = 0; iiY < rows; iiY++)
  {
    // For the front, go right to left for odd rows, left to right for even rows. Weaving back and forth rather
    // than always restarting each row on the same side allows us the graphics hardware to reuse cached vertex
    // calculations, per Apple's best practices.
    // Build the back at the same time by scanning in reverse.
    rowOffset = iiY * vCountX;
    lastRow   = (iiY == rows);
    oddRow    = (iiY & 1);
    for (iiX = 0; iiX <= columns; iiX++) 
    {
      if (oddRow)
      {
        frontStrip_[index]  = rowOffset + columns - iiX + vCountX;
        backStrip_[index++] = rowOffset + iiX + vCountX;
        frontStrip_[index]  = rowOffset + columns - iiX;
        backStrip_[index++] = rowOffset + iiX;
      }
      else
      {
        frontStrip_[index]  = rowOffset + iiX + vCountX;
        backStrip_[index++] = rowOffset + columns - iiX + vCountX;
        frontStrip_[index]  = rowOffset + iiX;
        backStrip_[index++] = rowOffset + columns - iiX;
      }
    } 
    // Unless we're on the last row, insert a degenerate vertex to enable us to connect to the next row.
    if (!lastRow)
    {
      if (oddRow)
      {
        frontStrip_[index]  = rowOffset + vCountX;
        backStrip_[index]   = rowOffset + vCountX + columns;
      }
      else
      {
        frontStrip_[index]  = rowOffset + vCountX + columns;
        backStrip_[index]   = rowOffset + vCountX;
      }
      index++;
    }
  }
}

@end







