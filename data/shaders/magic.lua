return [[
	#ifdef PIXEL
	extern number width;
	extern number height;
	extern number time;

	vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc) {
		sc.x = sc.x / width + cos(time*16+sc.y*128) / 128;
		sc.y = sc.y / height + cos(time*16+sc.x*32) / 128;
		return Texel(texture, sc) * vec4(0.65, 0.3, 0.82, 1.0);
	}
	#endif
]]
