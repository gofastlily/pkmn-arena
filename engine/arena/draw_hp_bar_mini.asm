DrawHPMini:
; Draws the HP bar in the stats screen
	call GetPredefRegisters
	ld a, $1
	jr DrawHPMini_

DrawHPMini2:
; Draws the HP bar in the party screen
	call GetPredefRegisters
	ld a, $2

DrawHPMini_:
	ld [wHPBarType], a
	push hl
	ld a, [wLoadedMonHP]
	ld b, a
	ld a, [wLoadedMonHP + 1]
	ld c, a
	or b
	jr nz, .nonzeroHP
	xor a
	ld c, a
	ld e, a
	ld a, $2
	ld d, a
	jp .drawHPMiniBar
.nonzeroHP
	ld a, [wLoadedMonMaxHP]
	ld d, a
	ld a, [wLoadedMonMaxHP + 1]
	ld e, a
	predef HPBarMiniLength
	ld a, $2
	ld d, a
	ld c, a
.drawHPMiniBar
	pop hl
	push de
	push hl
	push hl
	call DrawHPBarMini
	pop hl
	pop hl
	pop de
	ret


DrawHPBarMini::
; Draw an HP bar d tiles long, and fill it to e pixels.
; If c is nonzero, show at least a sliver regardless.
; The right end of the bar changes with [wHPBarType].

	push hl
	push de

	; Left
	ld a, [wWhichPokemon]
	cp 0
	jr z, .startLeft
	cp 3
	jr z, .startLeft
	ld a, $C1  ; between
	jr .endStart
.startLeft
	ld a, $C0  ; left
.endStart
	ld [hli], a

	push hl

	; Middle
	ld a, $63  ; empty
.draw
	ld [hli], a
	dec d
	jr nz, .draw

	; Right
	ld a, [wHPBarType]
	dec a
	ld a, $6c  ; status screen and battle
	jr z, .ok
	dec a ; pokemon menu
.ok
	ld [hl], a

	pop hl

	ld a, e
	and a
	jr nz, .fill

	; If c is nonzero, draw a pixel anyway.
	ld a, c
	and a
	jr z, .done
	ld e, 1

.fill
	ld a, e
	sub 8
	jr c, .partial
	ld e, a
	ld a, $6b  ; full
	ld [hli], a
	ld a, e
	and a
	jr z, .done
	jr .fill

.partial
	; Fill remaining pixels at the end if necessary.
	ld a, $63  ; empty
	add e
	ld [hl], a
.done
	pop de
	pop hl
	ret
