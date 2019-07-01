layout(triangle_strip, max_vertices = 3) out;
layout(triangles) in;

uniform sampler2D sDisplaceMap;
uniform sampler2D sMoveMap;
uniform vec3 uDisplaceGain;

in vec3 ioUVUnwrapCoord[];
in Vertex
{
	vec4 color;
	vec3 worldSpacePos;
	vec3 worldSpaceNorm;
	vec2 texCoord0;
	flat int cameraIndex;
} iVert[];

out Vertex
{
	vec4 color;
	vec3 worldSpacePos;
	vec3 worldSpaceNorm;
	vec2 texCoord0;
	flat int cameraIndex;
} oVert;

void main()
{

	// calculate new pos using displace map
	vec4 newPos[3];
	for (int i = 0; i < 3; i++)
	{
		newPos[i] = gl_in[i].gl_Position;
		newPos[i].z += texture(sDisplaceMap, ioUVUnwrapCoord[i].st).r * uDisplaceGain.z;
		newPos[i].xy += (texture(sMoveMap, ioUVUnwrapCoord[i].st).rg - vec2(0.5)) * uDisplaceGain.xy;
	}
	
	// find center of triange and use that tex coord
	vec2 newTexCoord0 = (iVert[0].texCoord0 + iVert[1].texCoord0 + iVert[2].texCoord0) / 3.0; 
	vec4 d1 = newPos[0] - newPos[1];
	vec4 d2 = newPos[0] - newPos[2];
	vec3 newNormal = cross(d1.xyz, d2.xyz);

	for (int i = 0; i < 3; i++)
	{
		oVert.color = iVert[i].color;
		oVert.worldSpacePos = iVert[i].worldSpacePos;
		oVert.worldSpaceNorm = newNormal; //iVert[i].worldSpaceNorm;
		oVert.texCoord0 = iVert[i].texCoord0;
		oVert.cameraIndex = iVert[i].cameraIndex;
		gl_Position = TDWorldToProj(newPos[i], ioUVUnwrapCoord[i], iVert[i].cameraIndex);

		EmitVertex();
	}

	EndPrimitive();
}
