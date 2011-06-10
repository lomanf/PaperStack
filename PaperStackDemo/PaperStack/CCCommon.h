/*
 *  CCCommon.h
 *  ConeCurl
 *
 *  Created by W. Dana Nuon on 4/18/10.
 *  Copyright 2010 lunaray. All rights reserved.
 *
 *  Portions borrowed and slightly modified from Jeff LaMarche's incredibly informative OpenGL ES tutorials:
 *  http://iphonedevelopment.blogspot.com/2009/05/opengl-es-from-ground-up-table-of.html
 *
 */

#define USE_TRIANGLE_STRIPS     1
#define SHOW_DEBUG_LINES        1
#define PAGE_COLUMNS            40
#define PAGE_ROWS               60

#define M_PI_HALF               M_PI * 0.5

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0f * M_PI)
#define RAD (180.0f / M_PI)

typedef struct
{
	CGFloat	x;
	CGFloat y;
} Vector2f;
typedef Vector2f Vertex2f;

typedef struct
{
	u_int x;
	u_int y;
} Vector2ui;
typedef Vector2ui Vertex2ui;

typedef struct
{
	CGFloat	x;
	CGFloat y;
	CGFloat z;
} Vector3f;
typedef Vector3f Vertex3f;

typedef struct
{
	u_int x;
	u_int y;
	u_int z;
} Vector3ui;
typedef Vector3ui Vertex3ui;

typedef struct
{
	u_char r;
	u_char g;
	u_char b;
	u_char a;
} Color4b;

typedef struct {
	Vertex3f v1;
	Vertex3f v2;
	Vertex3f v3;
} Triangle3D;

static inline Vertex2f Vertex2fMake(CGFloat inX, CGFloat inY)
{
	Vertex2f ret;
	ret.x = inX;
	ret.y = inY;
	return ret;
}

static inline void Vertex2fSet(Vertex2f *vertex, CGFloat inX, CGFloat inY)
{
  vertex->x = inX;
  vertex->y = inY;
}

static inline Vertex2ui Vertex2uiMake(u_int inX, u_int inY)
{
	Vertex2ui ret;
	ret.x = inX;
	ret.y = inY;
	return ret;
}

static inline void Vertex2uiSet(Vertex2ui *vertex, u_int inX, u_int inY)
{
  vertex->x = inX;
  vertex->y = inY;
}

static inline Vector2f Vector2fMake(CGFloat inX, CGFloat inY)
{
	Vector2f ret;
	ret.x = inX;
	ret.y = inY;
	return ret;
}

static inline Vector2ui Vector2uiMake(u_int inX, u_int inY)
{
	Vector2ui ret;
	ret.x = inX;
	ret.y = inY;
	return ret;
}

static inline Vertex3f Vertex3fMake(CGFloat inX, CGFloat inY, CGFloat inZ)
{
	Vertex3f ret;
	ret.x = inX;
	ret.y = inY;
	ret.z = inZ;
	return ret;
}

static inline void Vertex3fSet(Vertex3f *vertex, CGFloat inX, CGFloat inY, CGFloat inZ)
{
  vertex->x = inX;
  vertex->y = inY;
  vertex->z = inZ;
}

static inline Vertex3ui Vertex3uiMake(u_int inX, u_int inY, u_int inZ)
{
	Vertex3ui ret;
	ret.x = inX;
	ret.y = inY;
	ret.z = inZ;
	return ret;
}

static inline void Vertex3uiSet(Vertex3ui *vertex, u_int inX, u_int inY, u_int inZ)
{
  vertex->x = inX;
  vertex->y = inY;
  vertex->z = inZ;
}

static inline Vector3f Vector3fMake(CGFloat inX, CGFloat inY, CGFloat inZ)
{
	Vector3f ret;
	ret.x = inX;
	ret.y = inY;
	ret.z = inZ;
	return ret;
}

static inline Vector3ui Vector3uiMake(u_int inX, u_int inY, u_int inZ)
{
	Vector3ui ret;
	ret.x = inX;
	ret.y = inY;
	ret.z = inZ;
	return ret;
}

static inline Color4b Color4bMake(u_char inR, u_char inG, u_char inB, u_char inA)
{
	Color4b ret;
	ret.r = inR;
	ret.g = inG;
	ret.b = inB;
	ret.a = inA;
	return ret;
}

static inline Triangle3D Triangle3DMake(Vertex3f inV1, Vertex3f inV2, Vertex3f inV3)
{
	Triangle3D ret;
	ret.v1 = inV1;
	ret.v2 = inV2;
	ret.v3 = inV3;
	return ret;
}

static inline void QuadToTrianglesWindCWSet(u_short *vertex, CGFloat ul, CGFloat ur, CGFloat ll, CGFloat lr)
{
  // Break a quad into two triangles, since OpenGL ES does not support quads. Clockwise winding.
  vertex[0] = lr;
  vertex[1] = ll;
  vertex[2] = ul;
  vertex[3] = lr;
  vertex[4] = ul;
  vertex[5] = ur;
}

static inline void QuadToTrianglesWindCCWSet(u_short *vertex, CGFloat ul, CGFloat ur, CGFloat ll, CGFloat lr)
{
  // Break a quad into two triangles, since OpenGL ES does not support quads. Counter-clockwise winding.
  vertex[0] = lr;
  vertex[1] = ul;
  vertex[2] = ll;
  vertex[3] = lr;
  vertex[4] = ur;
  vertex[5] = ul;
}

static inline float vectorMagnitude( Vector3f vector ){
    return sqrt((vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z)); 
}

static inline void normalizeVector(Vector3f *vector)
{
    float vecMag = vectorMagnitude(*vector);
    vector->x /= vecMag;
    vector->y /= vecMag;
    vector->z /= vecMag;
}


static inline Vector3f Vector3DMakeWithStartAndEndPoints(Vertex3f start, Vertex3f end)
{
    Vector3f ret;
    ret.x = end.x - start.x;
    ret.y = end.y - start.y;
    ret.z = end.z - start.z;
    normalizeVector(&ret);
    return ret;
}

static inline Vector3f Triangle3DCalculateSurfaceNormal( Triangle3D triangle )
{
    Vector3f u = Vector3DMakeWithStartAndEndPoints(triangle.v2, triangle.v1);
    Vector3f v = Vector3DMakeWithStartAndEndPoints(triangle.v3, triangle.v1);
    
    Vector3f ret;
    ret.x = (u.y * v.z) - (u.z * v.y);
    ret.y = (u.z * v.x) - (u.x * v.z);
    ret.z = (u.x * v.y) - (u.y * v.x);
    return ret;
}

static inline CGFloat funcLinear(CGFloat ft, CGFloat f0, CGFloat f1)
{
  // Linear interpolation between f0 and f1
	return f0 + (f1 - f0) * ft;	
}

static inline CGFloat funcQuad(CGFloat ft, CGFloat f0, CGFloat f1)
{
  // Quadratic interpolation between f0 and f1
	return f0 + (f1 - f0) * ft * ft;	
}

static inline CGFloat funcPower(CGFloat ft, CGFloat f0, CGFloat f1, CGFloat p)
{
  // Exponential interpolation between f0 and f1
	return f0 + (f1 - f0) * pow(ft, p);
}
