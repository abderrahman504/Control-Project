shader_type canvas_item;

uniform bool highlightEdge;
uniform vec3 hlColor;
const float lowerHLDist = 0.3;
const float upperHLDist = 0.5;



void fragment()
{
	COLOR = texture(TEXTURE, UV);
	if (highlightEdge)
	{
		float radius = sqrt(pow(UV.x-0.5, 2) + pow(UV.y-0.5, 2));
		if (radius < upperHLDist && radius > lowerHLDist)
		{
			COLOR = vec4(hlColor, COLOR.a);
		}
	}
}
