//
//  CCPage.m
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright 2010 lunaray. All rights reserved.
//


#import "PSPage.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "PSDrawings.h"
#import "PSKonstants.h"

@interface PSPage ()

// Empty category for "private" methods
- (void)createTriangleArray;
- (void)createTriangleStrip;
@end


@implementation PSPage

@synthesize delegate, hasReverseCurl;
@synthesize width, height, columns, rows;
@synthesize currentFrame, framesPerCycle;
@synthesize SP, P;


- (id)init
{
    self = [super init];
	if ( self )
	{
    
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
    if (outputInnerShadowMesh_ != NULL)
        free(outputInnerShadowMesh_);
    if (outputOuterShadowMesh_ != NULL)
        free(outputOuterShadowMesh_);
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

- (const Vertex3f *)innerShadowVertices
{
    return outputInnerShadowMesh_;
}

- (const Vertex3f *)outerShadowVertices
{
    return outputOuterShadowMesh_;
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
    
    if (outputInnerShadowMesh_ != NULL)
        free(outputInnerShadowMesh_);
    outputInnerShadowMesh_ = malloc(sizeof(Vertex3f) * numVertices_);
    if (outputOuterShadowMesh_ != NULL)
        free(outputOuterShadowMesh_);
    outputOuterShadowMesh_ = malloc(sizeof(Vertex3f) * numVertices_);
    
    
  u_short vi = 0;	// vertex index
  short iiX, iiY;
  CGFloat px, py;
  CGFloat offsetX = hasReverseCurl ? -width : 0.0;
  // Create our flat page geometry as a vertex array. Even though our page has two sides, we need to generate only one
  // set of vertices since the front and back are coplanar meshes.
  for (iiY = 0; iiY < vCountY; iiY++)
  {
    for (iiX = 0; iiX < vCountX; iiX++)
    {
      px = (CGFloat)iiX * width / columns + offsetX;
      py = (CGFloat)iiY * height / rows - (height*0.5);
      inputMesh_[vi].x = px;
      inputMesh_[vi].y = py;
      textureArray_[vi].x = (CGFloat)iiX / columns;
      textureArray_[vi].y = (CGFloat)(iiY) / rows;
      vi++;
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

- (void)deform
{     
    CGFloat time = fabs( PSVector(SP, P).x ) * kPSPageTimeCorrection; // iOS 5 Curl style
//    CGFloat time = PSDistance( SP, P ) * kPSPageTimeCorrection;   // iBooks Curl style
    CGFloat angle = roundf( ( ( PSAngle( SP, P ) + 0.00001 ) * ( P.y > SP.y ? 1.0 : -1.0 ) + 0.00001 ) * 1000.0f ) / 1000.0f;
    CGFloat side = angle >= 0 ? 1.0 : -1.0;
    BOOL upsideFlag = angle < 0;
    CGFloat upside = upsideFlag ? 1.0 : -1.0;
    
    if ( ( !hasReverseCurl && P.x < 0.0 ) || ( hasReverseCurl && P.x > 0.0 ) ) {
        time = kPSPageTimeCorrection - time;
    }

    NSLog(@"Time:%f",time);
    
    // interpolate cone base
    CGFloat RB = fmax( height/columns, ( time / M_PI ) );
    
    CGPoint checkPoint1 = CGPointMake( P.x + RB * cosf( angle ), P.y - RB * sinf( angle ) );
    CGPoint checkPoint2 = CGPointMake( 0, height*0.5*upside );
    CGFloat checkDistance = PSDistance( checkPoint1, checkPoint2 );
    CGFloat checkDeltaY = fabsf( checkPoint1.y - checkPoint2.y );
    CGFloat angleLimit;
    if ( hasReverseCurl ) {
        angleLimit = ( M_PI_HALF + asinf( checkDeltaY/checkDistance ) ) * side;
        angle = upsideFlag ? fmin( angleLimit, angle ) : fmax( angleLimit, angle );
    } else {
        angleLimit = ( M_PI_HALF - asinf( checkDeltaY/checkDistance ) ) * side;
        angle = upsideFlag ? fmax( angleLimit, angle ) : fmin( angleLimit, angle );
    }
    
    CGFloat sinangle, cosangle, sintetha, costheta;
    
    sinangle = sinf( angle );
    cosangle = cosf( angle );
    
    // interpolate theta
    CGFloat tt = fmin( fabs( angle ) / ( M_PI_HALF ), 1.0 );
    CGFloat theta = PSQuad( tt, 0.000001, 0.00001 ) * side;
    
    sintetha = sinf( theta );
    costheta = cosf( theta );
    
    // calculate cone apex
    CGFloat dist = RB * ( 1 / tanf( theta ) );
    CGPoint A = CGPointMake( P.x + dist * sinangle, P.y + dist * cosangle );
    if ( A.y < height*0.5 || A.y > -height*05 ) {
        if ( A.x < width ) {
            A.x = width;
        }
    }
    
    // shado

    CGPoint shadowPO = CGPointMake( 0, 0 );
    
    CGFloat shadowTheta = angle*2-theta;
    CGPoint shadowPV = CGPointMake( P.x, P.y + (-SP.y) );
    CGPoint shadowPT = PSRotatePointBy( shadowPV, P, shadowTheta );
    CGFloat spx = width * 0.5 * cosf(shadowTheta) * (hasReverseCurl?-1.0:1.0);
    CGFloat spy = width * 0.5 * sinf(shadowTheta) * (hasReverseCurl?-1.0:1.0);
    CGPoint shadowP = CGPointMake( shadowPT.x + spx, shadowPT.y - spy );
    
    // deform mash
    
    Vertex2f  vi;
    CGPoint vp, vn;
    CGFloat ttheta, alpha, ipo, normal, dx, dy, R, Rc, beta, gamma, shadow, shadowval, shadowsidex, shadowsidey;
    Vertex3f  v1, vis1, vos1;
    Vertex3f *vo, *viso, *voso;
    BOOL vertexFlag;
    CGFloat reverseShadowRatio = hasReverseCurl ? -1.0 : 1.0;
    
    for ( u_short ii = 0; ii < numVertices_; ii++ ) {
        vi = inputMesh_[ ii ];
        
        vp = CGPointMake( vi.x, vi.y );
        alpha = PSAngle( vp, P ) + ( vp.y > P.y ? angle : -angle );
        ipo = PSDistance( P, vp );
        normal = ipo * cosf( alpha );
        dx = normal * cosangle;
        dy = normal * sinangle;
        vn = CGPointMake( vp.x - dx, vp.y + dy );
        
        ttheta = theta;
        
        R = PSDistance( vp, A ); 
        Rc = R * sintetha;
        beta = asinf( normal / R ) / sintetha;
        
        vertexFlag = hasReverseCurl ? ( vp.x > vn.x ) : ( vp.x < vn.x );
        
        if ( vertexFlag ) {
            
            v1.x = vp.x;
            v1.y = vp.y;
            v1.z = 0.0;
            
            vis1.x = vp.x;
            vis1.y = vp.y;
            vis1.z = 0.0;
            
            vos1.x  = v1.x;
            vos1.y  = v1.y;
            vos1.z  = 0;
            
        } else {
        
            // translate vertex
            if ( abs(beta) >= 0 && abs(beta) <= M_PI * 0.95 ) {
                // dynamic cone distortion
                v1.x  = vn.x + Rc * sinf( beta ) * cosangle;
                v1.y  = vn.y - Rc * sinf( beta ) *  costheta * sinangle;
                v1.z  = Rc * ( 1.0 - cosf( beta ) ) * costheta;
                
            } else {
                // flip over normal
                v1.x  = vn.x;
                v1.y  = vn.y;
                v1.z  = Rc * ( 1.0 - cosf( M_PI ) ) * costheta;
                CGFloat nredux = ( fabs( normal ) - fabs( Rc * M_PI ) ) * side;
                v1.x -= nredux * cosangle * side;
                v1.y += nredux * sinangle * side;
            }
            
            vis1.x  = v1.x;
            vis1.y  = v1.y;
            vis1.z  = v1.z;
            
            vos1.x  = v1.x;
            vos1.y  = v1.y;
            vos1.z  = v1.z;
                
            gamma = PSAngle( shadowP, CGPointMake( vis1.x, vis1.y ) );
            shadow = fmax(fabs(beta)-M_PI_HALF, 0.0) / M_PI_HALF;
            shadowsidey = vis1.y > shadowP.y ? 1.0 : -1.0;
            shadowval = fmin( shadow * fmax(0.075, RB), RB * 0.75 );
            vis1.x -= shadowval * cosf( gamma );
            vis1.y += shadowval * sinf( gamma ) * shadowsidey;
            
            if ( fabs(beta)<M_PI_HALF && fabs(beta) > 0.1 && NO ) {
                gamma = PSAngle( shadowPO, CGPointMake( vos1.x, vos1.y ) );
                shadowsidex = vos1.x < shadowPO.x ? -1.0 : 1.0;
                shadowsidey = vos1.y > shadowPO.y ? 1.0 : -1.0;
                shadow = M_PI / fabs(beta);
                shadowval = RB * 0.75;
                shadowval = 0;
                vos1.x -= shadowval * cosf( gamma ) * shadowsidex * reverseShadowRatio;
                vos1.y += shadowval * sinf( gamma ) * shadowsidey;
            }
            
        }
        
        
        // output vertex
        vo = &outputMesh_[ ii ];
        viso = &outputInnerShadowMesh_[ ii ];
        voso = &outputOuterShadowMesh_[ ii ];
        vo->x = v1.x;
        vo->y = v1.y;
        vo->z = v1.z;
        
        viso->x = vis1.x;
        viso->y = vis1.y;
        viso->z = vis1.z;
        
        voso->x = vos1.x;
        voso->y = vos1.y;
        voso->z = vos1.z;
    }
    
    [delegate pageDidFinishDeformWithAngle:angle andTime:time point:P theta:theta];
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







