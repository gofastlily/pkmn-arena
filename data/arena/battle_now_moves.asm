BattleNowTeamMovesR1A:
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


BattleNowTeamMovesR1B:
	ld hl, wPartyMon1Moves
	ld a, THUNDERBOLT
	ld [hli], a
	ld a, SUPERSONIC
	ld [hli], a
	ld a, THUNDER_WAVE
	ld [hli], a
	ld a, SWIFT
	ld [hl], a

	ld hl, wPartyMon2Moves
	ld a, MEGA_DRAIN
	ld [hli], a
	ld a, SLEEP_POWDER
	ld [hli], a
	ld a, DOUBLE_EDGE
	ld [hli], a
	ld a, PETAL_DANCE
	ld [hl], a

	ld hl, wPartyMon3Moves
	ld a, FLAMETHROWER
	ld [hli], a
	ld a, CONFUSE_RAY
	ld [hli], a
	ld a, DIG
	ld [hli], a
	ld a, FIRE_BLAST
	ld [hl], a

	ld hl, wPartyMon4Moves
	ld a, SURF
	ld [hli], a
	ld a, DISABLE
	ld [hli], a
	ld a, CONFUSION
	ld [hli], a
	ld a, ICE_BEAM
	ld [hl], a

	ld hl, wPartyMon5Moves
	ld a, EARTHQUAKE
	ld [hli], a
	ld a, FOCUS_ENERGY
	ld [hli], a
	ld a, SUBMISSION
	ld [hli], a
	ld a, BODY_SLAM
	ld [hl], a

	ld hl, wPartyMon6Moves
	ld a, FURY_SWIPES
	ld [hli], a
	ld a, GROWL
	ld [hli], a
	ld a, THUNDER
	ld [hli], a
	ld a, TAKE_DOWN
	ld [hl], a
	ret


BattleNowTeamMovesDebug:
	ld hl, wPartyMon1Moves
	ld a, PSYCHIC_M
	ld [hli], a
	ld a, THUNDERBOLT
	ld [hli], a
	ld a, ICE_BEAM
	ld [hli], a
	ld a, RECOVER
	ld [hl], a
	ret
