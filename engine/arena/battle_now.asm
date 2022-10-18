SetBattleNowTeam:
	ld de, BattleNowTeamR1A
.loop
	ld a, [de]
	cp -1
	ret z
	ld [wcf91], a
	inc de
	ld a, [de]
	ld [wCurEnemyLVL], a
	inc de
	call AddPartyMon
	jr .loop


BattleNowTeamR1A:
	db PIKACHU, 50
	db BULBASAUR, 50
	db CHARMANDER, 50
	db SQUIRTLE, 50
	db SANDSHREW, 50
	db CLEFAIRY, 50
	db -1 ; end


BattleNowTeamR1B:
	db MAGNEMITE, 50
	db ODDISH, 50
	db VULPIX, 50
	db PSYDUCK, 50
	db CUBONE, 50
	db MEOWTH, 50
	db -1 ; end


BattleNowStart:
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a

	; Get all badges
	ld a, 1 << BIT_EARTHBADGE
	ld [wObtainedBadges], a

	call SetBattleNowTeam

	ld hl, wPartyMon1Moves
	ld a, THUNDERBOLT
	ld [hli], a
	ld a, QUICK_ATTACK
	ld [hli], a
	ld a, THUNDER_WAVE
	ld [hli], a
	ld a, SWIFT
	ld [hl], a

	ld hl, wPartyMon2Moves
	ld a, RAZOR_LEAF
	ld [hli], a
	ld a, SLEEP_POWDER
	ld [hli], a
	ld a, LEECH_SEED
	ld [hli], a
	ld a, CUT
	ld [hl], a

	ld hl, wPartyMon3Moves
	ld a, FLAMETHROWER
	ld [hli], a
	ld a, BIDE
	ld [hli], a
	ld a, DIG
	ld [hli], a
	ld a, SLASH
	ld [hl], a

	ld hl, wPartyMon4Moves
	ld a, SURF
	ld [hli], a
	ld a, WITHDRAW
	ld [hli], a
	ld a, STRENGTH
	ld [hli], a
	ld a, ICE_BEAM
	ld [hl], a

	ld hl, wPartyMon5Moves
	ld a, EARTHQUAKE
	ld [hli], a
	ld a, SAND_ATTACK
	ld [hli], a
	ld a, SUBMISSION
	ld [hli], a
	ld a, ROCK_SLIDE
	ld [hl], a

	ld hl, wPartyMon6Moves
	ld a, DOUBLESLAP
	ld [hli], a
	ld a, METRONOME
	ld [hli], a
	ld a, THUNDER
	ld [hli], a
	ld a, MEGA_PUNCH
	ld [hl], a

	ret
