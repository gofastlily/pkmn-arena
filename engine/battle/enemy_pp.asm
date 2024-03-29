; Taken from shinpokered
; https://github.com/jojobear13/shinpokered/commit/25cd110ee5dde048523c2dc19fb2a007d5c89e5b

; Custom functions for determining which Trainer AI Pokémon have already been sent out before
; The zero flag returns the bit state, 1 means the Pokémon has been sent out already
CheckAISentOut:
	ld a, [wWhichPokemon]	
	cp $05
	jr z, .party5
	cp $04
	jr z, .party4
	cp $03
	jr z, .party3
	cp $02
	jr z, .party2
	cp $01
	jr z, .party1
	jr .party0
.party5
	ld a, [wFontLoaded]
	bit 6, a
	jr .partyret
.party4
	ld a, [wFontLoaded]
	bit 5, a
	jr .partyret
.party3
	ld a, [wFontLoaded]
	bit 4, a
	jr .partyret
.party2
	ld a, [wFontLoaded]
	bit 3, a
	jr .partyret
.party1
	ld a, [wFontLoaded]
	bit 2, a
	jr .partyret
.party0
	ld a, [wFontLoaded]
	bit 1, a
.partyret
	ret


; Track PP for enemies both trainer and wild
ChooseMovePPTrack:
	; retrieve hl pointer
	ld a, [wEnemyPowerPointsPointer]
	ld h, a
	ld a, [wEnemyPowerPointsPointer + 1]
	ld l, a	
	ld a, e  ; retrieve move number
	ld b, a
    ; b holds the move slot (1 to 4)

	call IsTrainerBattlePPCheck

	ld a, b
	dec a
	ld [wEnemyMoveListIndex], a
    ; is move disabled?
	ld a, [wEnemyDisabledMove]
	swap a
	and $f
	cp b
	jp z, .flagset
    ; is the move non-existant?
	ld a, [hl]
	and a
	jp z, .flagset
    ; now check the PP for the slot specified by "b"
	push hl
	ld hl, wEnemyMonPP
	push bc
	ld c, b
	ld b, 0
	dec bc
	add hl, bc
	pop bc
	ld a, [hl]
	and a
	jr z, .PPexhausted
.PPremaining
	dec a
	ld [hl], a
	ld a, 1
	ld e, a  ; return nz flag if there was PP left
	push bc
	call TransformPPtasks
	pop bc
	pop hl
	jp .back
.PPexhausted  ; return zero flag if no PP left
	pop hl
.flagset
	xor a
	ld e, a
	ld a,  b
	cp 4
	jr z, .move4
	cp 3
	jr z, .move3
	cp 2
	jr z, .move2
.move1
	set 0, d
	jr .back
.move2
	set 1, d
	jr .back
.move3
	set 2, d
	jr .back
.move4
	set 3, d
.back
	ld a, h
	ld [wEnemyPowerPointsPointer], a
	ld a, l
	ld [wEnemyPowerPointsPointer + 1], a
	ret


IsTrainerBattlePPCheck:
	ld a, [wIsInBattle]
	cp 2
	ret nz
	push de
	push hl
	push bc
	
.loop1
	dec b
	jr z, .doneloop1
	dec hl
	jr .loop1
.doneloop1

	ld c, NUM_MOVES
	ld de, wEnemyMonPP
.loop2
	ld a, [de]
	ld b, a
	ld a, [hl]	
	and b
	jr nz, .done	
	inc hl
	inc de
	dec c
	jr nz, .loop2
.done
	; zero flag set by this point if all moves were ran through
	pop bc
	pop hl
	pop de
	ret nz
	ld hl, wEnemyMonMoves
	push bc
	ld c, b
	ld b, 0
	dec bc
	add hl, bc
	pop bc
	ret


; if trainer uses transform, then write transform PP to party struct
TransformPPtasks:
	ld a, [wIsInBattle]
	cp 2
	ret z

	ld c, b
	ld b, 0
	dec bc
	
	ld hl, wEnemyMonMoves
	add hl, bc
	ld a, [hl]
	cp TRANSFORM
	ret nz
	
	ld hl, wEnemyMonPP
	add hl, bc
	ld a, [hl]
	push af
	
	ld hl, wEnemyMon1PP
	add hl, bc
	ld a, [wEnemyMonPartyPos]
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	
	pop af
	ld [hl], a
	ret


AdvancedLoadPP:
	ld a, [wIsInBattle]
	cp 1
	jr z, .doRegular  ; don't do anything special for wild battles
	; else see if the mon has been sent out before
	call CheckAISentOut
	jr z, .doRegular ; don't do anything special if the mon has not been out before

	; else load its PPs from the wEnemyMonxPP
	ld a, [wWhichPokemon]
	ld hl, wEnemyMon1PP
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	; HL now points to wEnemyMonxPP
	ld de, wEnemyMonPP
	ld bc, $0004
	call CopyData  ; copy the pp data from wEnemyMonxPP to wEnemyMonPP
	ret
.doRegular
	ld hl, wEnemyMonMoves
	ld de, wEnemyMonPP - 1
	predef LoadMovePPs
	ret
