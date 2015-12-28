return [[
	#ifdef PIXEL
	extern number width;
	extern number height;
	extern number time;
	extern number strength;

	vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc) {
		sc.x = sc.x / width + cos(time*16+sc.y/8) / 128 * strength;
		sc.y = sc.y / height;
		vec4 c = (1.0-strength)*vec4(1.0, 1.0, 1.0, 1.0) + strength*vec4(0.65, 0.3, 0.82, 1.0);
		return Texel(texture, sc) * c;
	}
	#endif
]]
