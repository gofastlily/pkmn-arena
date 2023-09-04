ArenaLoadPartyPokeballGfx:
	ld de, PokeballTileGraphics
	ld hl, vChars1 tile $40
	lb bc, BANK(PokeballTileGraphics), (PokeballTileGraphicsEnd - PokeballTileGraphics) / $10
	jp CopyVideoData
