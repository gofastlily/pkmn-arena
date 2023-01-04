StartBattleNow:
	call PrepBattleNow
	predef HealParty
	call NewBattle
	call SoftReset


SetBattleNowTeam:
	; Manually set level for whole team
IF DEF(_DEBUG)
	ld a, 100
ELSE
	ld a, 50
ENDC
	ld b, a
.loop
	ld a, [de]
	cp -1
	ret z
	ld [wcf91], a
	inc de
	ld a, b
	ld [wCurEnemyLVL], a
	call AddPartyMon
	jr .loop
	ret


SetBattleNowTeamR1A:
	ld de, BattleNowTeamR1A
	call SetBattleNowTeam
	callfar BattleNowTeamMovesR1A
	ret


SetBattleNowTeamR1B:
	ld de, BattleNowTeamR1B
	call SetBattleNowTeam
	callfar BattleNowTeamMovesR1B
	ret


BattleNowTeamR1A:
	db PIKACHU, BULBASAUR, CHARMANDER, SQUIRTLE, SANDSHREW, CLEFAIRY, -1


BattleNowTeamR1B:
	db MAGNEMITE, ODDISH, VULPIX, PSYDUCK, CUBONE, MEOWTH, -1


BattleNowTeamDebug:
	db MEWTWO, MEW, DRAGONITE, ARTICUNO, ZAPDOS, MOLTRES, -1 ; end


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
	callfar BattleNowTeamMovesDebug
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
