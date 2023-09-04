ArenaWriteMonPartySpriteOAMByPartyIndex:
; Write OAM blocks for the party mon in [hPartyMonIndex].
	push hl
	push de
	push bc
	ldh a, [hPartyMonIndex]
	cp $ff
	jr z, .asm_7191f
	ld hl, wPartySpecies
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	call ArenaGetPartyMonSpriteID
	ld [wOAMBaseTile], a
	call ArenaWriteMonPartySpriteOAM
	pop bc
	pop de
	pop hl
	ret

.asm_7191f
	ld hl, wShadowOAM
	ld de, wMonPartySpritesSavedOAM
	ld bc, $60
	call CopyData
	pop bc
	pop de
	pop hl
	ret


ArenaWriteMonPartySpriteOAM:
; Write the OAM blocks for the first animation frame into the OAM buffer and
; make a copy at wMonPartySpritesSavedOAM.
	push af
	ld a, [wMonDataLocation]
	cp 0
	jp z, .playerIndices
	ld a, [wArenaBattleTempCpuRosterIndex]
	cp 0
	jp z, .enemyIndexZero
	cp 1
	jp z, .enemyIndexOne
	cp 2
	jp z, .enemyIndexTwo
	cp 3
	jp z, .enemyIndexThree
	cp 4
	jp z, .enemyIndexFour
	cp 5
	jp z, .enemyIndexFive
	jp .endIndex
.playerIndices
	ld a, [wArenaBattleTempCpuRosterIndex]
	cp 0
	jp z, .playerIndexZero
	cp 1
	jp z, .playerIndexOne
	cp 2
	jp z, .playerIndexTwo
	cp 3
	jp z, .playerIndexThree
	cp 4
	jp z, .playerIndexFour
	cp 5
	jp z, .playerIndexFive
	jp .endIndex
.enemyIndexZero
	ld c, $20  ; 0 & 3
	ld b, $68  ; 0, 1, & 2
	jp .endIndex
.enemyIndexOne
	ld c, $38  ; 1 & 4
	ld b, $68  ; 0, 1, & 2
	jp .endIndex
.enemyIndexTwo
	ld c, $50  ; 2 & 5
	ld b, $68  ; 0, 1, & 2
	jp .endIndex
.enemyIndexThree
	ld c, $20  ; 0 & 3
	ld b, $80  ; 3, 4, & 5
	jp .endIndex
.enemyIndexFour
	ld c, $38  ; 1 & 4
	ld b, $80  ; 3, 4, & 5
	jp .endIndex
.enemyIndexFive
	ld c, $50  ; 2 & 5
	ld b, $80  ; 3, 4, & 5
	jp .endIndex
.playerIndexZero
	ld c, $50  ; 0 & 3
	ld b, $20  ; 0, 1, & 2
	jp .endIndex
.playerIndexOne
	ld c, $68  ; 1 & 4
	ld b, $20  ; 0, 1, & 2
	jp .endIndex
.playerIndexTwo
	ld c, $80  ; 2 & 5
	ld b, $20  ; 0, 1, & 2
	jp .endIndex
.playerIndexThree
	ld c, $50  ; 0 & 3
	ld b, $38  ; 3, 4, & 5
	jp .endIndex
.playerIndexFour
	ld c, $68  ; 1 & 4
	ld b, $38  ; 3, 4, & 5
	jp .endIndex
.playerIndexFive
	ld c, $80  ; 2 & 5
	ld b, $38  ; 3, 4, & 5
.endIndex
	ld h, HIGH(wShadowOAM)
	ldh a, [hPartyMonIndex]
	swap a
	ld l, a
	pop af
	cp ICON_HELIX << 2
	jr z, .helix
	call WriteSymmetricMonPartySpriteOAM
	jr .makeCopy
.helix
	call WriteAsymmetricMonPartySpriteOAM
; Make a copy of the OAM buffer with the first animation frame written so that
; we can flip back to it from the second frame by copying it back.
.makeCopy
	ld hl, wShadowOAM
	ld de, wMonPartySpritesSavedOAM
	ld bc, $60
	jp CopyData


ArenaGetPartyMonSpriteID:
	ld [wd11e], a
	predef IndexToPokedex
	ld a, [wd11e]
	ld c, a
	dec a
	srl a
	ld hl, MonPartyData
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	bit 0, c
	jr nz, .skipSwap
	swap a ; use lower nybble if pokedex num is even
.skipSwap
	and $f0
	srl a ; value == ICON constant << 2
	srl a
	ret
