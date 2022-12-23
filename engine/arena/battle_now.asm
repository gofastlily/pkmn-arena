StartBattleNow:
	call PrepBattleNow
	predef HealParty
	call NewBattle
	call Init


SetBattleNowTeam:
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
	ret


SetBattleNowTeamR1A:
	ld de, BattleNowTeamR1A
	call SetBattleNowTeam
	call BattleNowTeamMovesR1A
	ret


SetBattleNowTeamR1B:
	ld de, BattleNowTeamR1B
	call SetBattleNowTeam
	call BattleNowTeamMovesR1B
	ret


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


BattleNowTeamDebug:
	db MEWTWO, 100
	db MEW, 100
	db DRAGONITE, 100
	db ARTICUNO, 100
	db ZAPDOS, 100
	db MOLTRES, 100
	db -1 ; end


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


BattleNowPickTeams:
	; Pick a random team of two
	call Random
	and %1
	jp nz, .teamB
	call SetBattleNowTeamR1A
	; Set Rival Team
	ld a, $5
	ld [wTrainerNo], a
	jp .teamDone
.teamB
	call SetBattleNowTeamR1B
	; Set Rival Team
	ld a, $4
	ld [wTrainerNo], a
	jp .teamDone
.teamDone
	ret


PrepBattleNow:
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a

	; Get all badges
	ld a, 1 << BIT_EARTHBADGE
	ld [wObtainedBadges], a

	; Prevent blackout message, seemingly not working
	ld a, OAKS_LAB
	ld [wCurMap], a

IF DEF(_DEBUG)
	ld de, BattleNowTeamDebug
	call SetBattleNowTeam
	call BattleNowTeamMovesDebug
	ld a, OPP_RIVAL1
	ld [wCurOpponent], a
	ld a, $1
	ld [wTrainerNo], a
ELSE
	; Face the Rival for now
	ld a, OPP_RIVAL3
	ld [wCurOpponent], a
	call BattleNowPickTeams
ENDC

	ret
