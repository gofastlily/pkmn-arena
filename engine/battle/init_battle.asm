InitBattle::
	; Clear battle temp values
	xor a
	ld [wArenaBattleTemp], a
	ld [wArenaRosterCountPlayer], a
	ld [wArenaRosterCountCpu], a
	ld [wArenaRosterTimerCpu], a
	ld [wArenaRosterCursorLocationY], a
	ld a, 3
	ld [wArenaRosterTargetCount], a

	ld a, [wCurOpponent]
	and a
	jr z, DetermineWildOpponent


InitOpponent:
	ld a, [wCurOpponent]
	ld [wcf91], a
	ld [wEnemyMonSpecies2], a
	jr InitBattleCommon


DetermineWildOpponent:
	ld a, [wd732]
	bit 1, a
	jr z, .notDebug
	ldh a, [hJoyHeld]
	bit BIT_B_BUTTON, a
	ret nz
.notDebug
	ld a, [wNumberOfNoRandomBattleStepsLeft]
	and a
	ret nz
	callfar TryDoWildEncounter
	ret nz
InitBattleCommon:
	ld a, [wMapPalOffset]
	push af
	ld hl, wLetterPrintingDelayFlags
	ld a, [hl]
	push af
	res 1, [hl]
	call InitBattleVariables
	ld a, [wEnemyMonSpecies2]
	sub OPP_ID_OFFSET
	jp c, InitWildBattle
	ld [wTrainerClass], a
	call GetTrainerInformation
	callfar ReadTrainer

	callfar ShowTeams
	; callfar WaitForButtonPressAB
	ld a, [wArenaBattleTemp]
	bit 7, a
	jp z, PickTeamsFromRoster

	callfar DoBattleTransitionAndInitBattleVariables
	call _LoadTrainerPic
	xor a
	ld [wEnemyMonSpecies2], a
	ldh [hStartTileID], a
	dec a
	ld [wAICount], a
	hlcoord 12, 0
	predef CopyUncompressedPicToTilemap
	ld a, $ff
	ld [wEnemyMonPartyPos], a
	ld a, $2
	ld [wIsInBattle], a

; Is this a major story battle?
	ld a, [wLoneAttackNo]
	and a
	jp z, _InitBattleCommon
	callabd_ModifyPikachuHappiness PIKAHAPPY_GYMLEADER ; useless since already in bank3d
	jp _InitBattleCommon


InitWildBattle:
	ld a, $1
	ld [wIsInBattle], a
	callfar LoadEnemyMonData
	callfar DoBattleTransitionAndInitBattleVariables
	ld a, [wCurOpponent]
	cp RESTLESS_SOUL
	jr z, .isGhost
	callfar IsGhostBattle
	jr nz, .isNoGhost
.isGhost
	ld hl, wMonHSpriteDim
	ld a, $66
	ld [hli], a   ; write sprite dimensions
	ld bc, GhostPic
	ld a, c
	ld [hli], a   ; write front sprite pointer
	ld [hl], b
	ld hl, wEnemyMonNick  ; set name to "GHOST"
	ld a, "G"
	ld [hli], a
	ld a, "H"
	ld [hli], a
	ld a, "O"
	ld [hli], a
	ld a, "S"
	ld [hli], a
	ld a, "T"
	ld [hli], a
	ld [hl], "@"
	ld a, [wcf91]
	push af
	ld a, MON_GHOST
	ld [wcf91], a
	ld de, vFrontPic
	call LoadMonFrontSprite ; load ghost sprite
	pop af
	ld [wcf91], a
	jr .spriteLoaded
.isNoGhost
	ld de, vFrontPic
	call LoadMonFrontSprite ; load mon sprite
.spriteLoaded
	xor a
	ld [wTrainerClass], a
	ldh [hStartTileID], a
	hlcoord 12, 0
	predef CopyUncompressedPicToTilemap


; common code that executes after init battle code specific to trainer or wild battles
_InitBattleCommon:
	ld b, SET_PAL_BATTLE_BLACK
	call RunPaletteCommand
	callfar SlidePlayerAndEnemySilhouettesOnScreen
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, .emptyString
	call PrintText
	call SaveScreenTilesToBuffer1
	call ClearScreen
	ld a, $98
	ldh [hAutoBGTransferDest + 1], a
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	ld a, $9c
	ldh [hAutoBGTransferDest + 1], a
	call LoadScreenTilesFromBuffer1
	hlcoord 9, 7
	lb bc, 5, 10
	call ClearScreenArea
	hlcoord 1, 0
	lb bc, 4, 10
	call ClearScreenArea
	call ClearSprites
	ld a, [wIsInBattle]
	dec a ; is it a wild battle?
	ld hl, DrawEnemyHUDAndHPBar
	ld b, BANK(DrawEnemyHUDAndHPBar)
	call z, Bankswitch ; draw enemy HUD and HP bar if it's a wild battle
	callfar StartBattle
	callfar EndOfBattle
	pop af
	ld [wLetterPrintingDelayFlags], a
	pop af
	ld [wMapPalOffset], a
	ld a, [wSavedTileAnimations]
	ldh [hTileAnimations], a
	scf
	ret
.emptyString
	db "@"


_LoadTrainerPic:
; wd033-wd034 contain pointer to pic
	ld a, [wTrainerPicPointer]
	ld e, a
	ld a, [wTrainerPicPointer + 1]
	ld d, a ; de contains pointer to trainer pic
	ld a, [wLinkState]
	and a
	ld a, BANK("Pics 6") ; this is where all the trainer pics are (not counting Red's)
	jr z, .loadSprite
	ld a, BANK(RedPicFront)
.loadSprite
	call UncompressSpriteFromDE
	ld de, vFrontPic
	ld a, $77
	ld c, a
	jp LoadUncompressedSpriteData


LoadMonBackPic:
; Assumes the monster's attributes have
; been loaded with GetMonHeader.
	ld a, [wBattleMonSpecies2]
	ld [wcf91], a
	hlcoord 1, 5
	lb bc, 7, 8
	call ClearScreenArea
	ld hl,  wMonHBackSprite - wMonHeader
	call UncompressMonSprite
	predef ScaleSpriteByTwo
	ld de, vBackPic
	call InterlaceMergeSpriteBuffers ; combine the two buffers to a single 2bpp sprite
	ld hl, vSprites
	ld de, vBackPic
	ld c, (2*SPRITEBUFFERSIZE)/16 ; count of 16-byte chunks to be copied
	ldh a, [hLoadedROMBank]
	ld b, a
	jp CopyVideoData


; animates the mon "growing" out of the pokeball
AnimateSendingOutMon:
	ld a, [wPredefHL]
	ld h, a
	ld a, [wPredefHL + 1]
	ld l, a
	ldh a, [hStartTileID]
	ldh [hBaseTileID], a
	ld b, $4c
	ld a, [wIsInBattle]
	and a
	jr z, .notInBattle
	add b
	ld [hl], a
	call Delay3
	ld bc, -(SCREEN_WIDTH * 2 + 1)
	add hl, bc
	ld a, 1
	ld [wDownscaledMonSize], a
	lb bc, 3, 3
	predef CopyDownscaledMonTiles
	ld c, 4
	call DelayFrames
	ld bc, -(SCREEN_WIDTH * 2 + 1)
	add hl, bc
	xor a
	ld [wDownscaledMonSize], a
	lb bc, 5, 5
	predef CopyDownscaledMonTiles
	ld c, 5
	call DelayFrames
	ld bc, -(SCREEN_WIDTH * 2 + 1)
	jr .next
.notInBattle
	ld bc, -(SCREEN_WIDTH * 6 + 3)
.next
	add hl, bc
	ldh a, [hBaseTileID]
	add $31
	jr CopyUncompressedPicToHL


CopyUncompressedPicToTilemap:
	ld a, [wPredefHL]
	ld h, a
	ld a, [wPredefHL + 1]
	ld l, a
	ldh a, [hStartTileID]
CopyUncompressedPicToHL::
	lb bc, 7, 7
	ld de, SCREEN_WIDTH
	push af
	ld a, [wSpriteFlipped]
	and a
	jr nz, .flipped
	pop af
.loop
	push bc
	push hl
.innerLoop
	ld [hl], a
	add hl, de
	inc a
	dec c
	jr nz, .innerLoop
	pop hl
	inc hl
	pop bc
	dec b
	jr nz, .loop
	ret

.flipped
	push bc
	ld b, 0
	dec c
	add hl, bc
	pop bc
	pop af
.flippedLoop
	push bc
	push hl
.flippedInnerLoop
	ld [hl], a
	add hl, de
	inc a
	dec c
	jr nz, .flippedInnerLoop
	pop hl
	dec hl
	pop bc
	dec b
	jr nz, .flippedLoop
	ret


TeamSelectionBlankPokeballs:
	ld a, [wArenaRosterTargetCount]
	cp 1
	jr z, .rosterOne
	cp 2
	jr z, .rosterTwo
	cp 3
	jr z, .rosterThree
	cp 4
	jr z, .rosterFour
	cp 5
	jr z, .rosterFive
	cp 6
	jr z, .rosterSix
	ret
.rosterSix
	ld a, $C3
	hlcoord 14, 7
	ld [hl], a
	ld a, $C3
	hlcoord 6, 16
	ld [hl], a
.rosterFive
	ld a, $C3
	hlcoord 13, 7
	ld [hl], a
	ld a, $C3
	hlcoord 5, 16
	ld [hl], a
.rosterFour
	ld a, $C3
	hlcoord 12, 7
	ld [hl], a
	ld a, $C3
	hlcoord 4, 16
	ld [hl], a
.rosterThree
	ld a, $C3
	hlcoord 11, 7
	ld [hl], a
	ld a, $C3
	hlcoord 3, 16
	ld [hl], a
.rosterTwo
	ld a, $C3
	hlcoord 10, 7
	ld [hl], a
	ld a, $C3
	hlcoord 2, 16
	ld [hl], a
.rosterOne
	ld a, $C3
	hlcoord 9, 7
	ld [hl], a
	ld a, $C3
	hlcoord 1, 16
	ld [hl], a
	ret


TeamSelectionPlayerPartyPokeballs:
	ld a, [wArenaRosterCountPlayer]
	cp 1
	jr z, .playerRosterOne
	cp 2
	jr z, .playerRosterTwo
	cp 3
	jr z, .playerRosterThree
	cp 4
	jr z, .playerRosterFour
	cp 5
	jr z, .playerRosterFive
	cp 6
	jr z, .playerRosterSix
	ret
.playerRosterSix
	ld a, $C0
	hlcoord 14, 7
	ld [hl], a
.playerRosterFive
	ld a, $C0
	hlcoord 13, 7
	ld [hl], a
.playerRosterFour
	ld a, $C0
	hlcoord 12, 7
	ld [hl], a
.playerRosterThree
	ld a, $C0
	hlcoord 11, 7
	ld [hl], a
.playerRosterTwo
	ld a, $C0
	hlcoord 10, 7
	ld [hl], a
.playerRosterOne
	ld a, $C0
	hlcoord 9, 7
	ld [hl], a
	ret


TeamSelectionEnemyPartyPokeballs:
	; ld a, [wArenaRosterCountCpu]
	; dec a
	; ld b, a
	; ld a, [wArenaRosterTargetCount]
	; cp b
	; ret c
	ld a, [wArenaRosterCountCpu]
	cp 1
	jr z, .enemyRosterOne
	cp 2
	jr z, .enemyRosterTwo
	cp 3
	jr z, .enemyRosterThree
	cp 4
	jr z, .enemyRosterFour
	cp 5
	jr z, .enemyRosterFive
	cp 6
	jr z, .enemyRosterSix
	ret
.enemyRosterSix
	ld a, $C0
	hlcoord 6, 16
	ld [hl], a
.enemyRosterFive
	ld a, $C0
	hlcoord 5, 16
	ld [hl], a
.enemyRosterFour
	ld a, $C0
	hlcoord 4, 16
	ld [hl], a
.enemyRosterThree
	ld a, $C0
	hlcoord 3, 16
	ld [hl], a
.enemyRosterTwo
	ld a, $C0
	hlcoord 2, 16
	ld [hl], a
.enemyRosterOne
	ld a, $C0
	hlcoord 1, 16
	ld [hl], a
	ret


PickTeamsFromRoster:
	callfar ArenaLoadPartyPokeballGfx

.pickRosterLoop
	; Draw the slots for Pokeballs so they can be overwritten later
	call TeamSelectionBlankPokeballs

	; Handle CPU selecting their team
	ld a, [wArenaRosterTargetCount]
	ld b, a
	ld a, [wArenaRosterCountCpu]
	cp b
	jp z, .skipEnemyRosterPokeball

	ld a, [wArenaRosterTimerCpu]
	ld b, a
	add a, 1
	ld [wArenaRosterTimerCpu], a
	ld b, a
	ld a, 45  ; three-quarters of a second delay between the CPU picking their team
	cp b
	jr nz, .skipEnemyRosterPokeball
	ld a, [wArenaRosterCountCpu]
	add a, 1
	ld [wArenaRosterCountCpu], a
	xor a
	ld [wArenaRosterTimerCpu], a
.skipEnemyRosterPokeball

	call HandleRosterInput

	ld a, 6
	call UpdateRosterCursorPosition

	; Draw pokéballs
	call TeamSelectionPlayerPartyPokeballs
	call TeamSelectionEnemyPartyPokeballs

	callfar DelayFrame
	ld a, [wArenaRosterCountPlayer]
	ld b, a
	ld a, [wArenaRosterTargetCount]
	cp b
	jp nz, .pickRosterLoop

	; Switch to Y/N prompt?
	callfar WaitForButtonPressAB

	; Mark team as selected
	ld a, [wArenaBattleTemp]
	set 7, a
	ld [wArenaBattleTemp], a
	; loop back to InitBattleCommon
	jp InitBattleCommon


UpdateRosterCursorPosition:
	hlcoord 8, 1
	ld de, SCREEN_WIDTH
	; add a
	ld c, a
.loop
	ld [hl], " "
	add hl, de
	dec c
	jr nz, .loop

	ld a, [wArenaRosterCountPlayer]
	ld b, a
	ld a, [wArenaRosterTargetCount]
	cp b
	ret z

	hlcoord 8, 1
	ld bc, SCREEN_WIDTH
	ld a, [wArenaRosterCursorLocationY]
	call AddNTimes
	ld [hl], "▶"
.end
	ret


HandleRosterInput:
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit BIT_B_BUTTON, a
	jr nz, .bPressed
	bit BIT_A_BUTTON, a
	jr nz, .aPressed
	bit BIT_D_DOWN, a
	jr nz, .downPressed
	bit BIT_D_UP, a
	jr nz, .upPressed
	ret
.aPressed
	call AddToRoster
	ret
.bPressed
	call RemoveFromRoster
	ret
.downPressed
	ld a, [wArenaRosterCursorLocationY]
	cp 5
	jp nz, .skipDownReset
	ld a, 255
.skipDownReset
	inc a
	ld [wArenaRosterCursorLocationY], a
	ret
.upPressed
	ld a, [wArenaRosterCursorLocationY]
	cp 0
	jp nz, .skipUpReset
	ld a, 6
.skipUpReset
	dec a
	ld [wArenaRosterCursorLocationY], a
	ret


AddToRoster:
	ld a, [wArenaRosterTargetCount]
	ld b, a
	ld a, [wArenaRosterCountPlayer]
	cp b
	ret z
	inc a
	ld [wArenaRosterCountPlayer], a
	cp 1
	jp z, .addOne
	cp 2
	jp z, .addTwo
	cp 3
	jp z, .addThree
	cp 4
	jp z, .addFour
	cp 5
	jp z, .addFive
	cp 6
	jp z, .addSix
	ret
.addOne
	; 1 add
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder]
	add b
	ld [wArenaRosterOrder], a
	ret
.addTwo
	; 2 swap add swap
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder]
	swap a
	add b
	swap a
	ld [wArenaRosterOrder], a
	ret
.addThree
	; 3 index+1 add
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder+1]
	add b
	ld [wArenaRosterOrder+1], a
	ret
.addFour
	; 4 index+1 swap add swap
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder+1]
	swap a
	add b
	swap a
	ld [wArenaRosterOrder+1], a
	ret
.addFive
	; 5 index+2 add
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder+2]
	add b
	ld [wArenaRosterOrder+2], a
	ret
.addSix
	; 6 index+2 swap add swap
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder+2]
	swap a
	add b
	swap a
	ld [wArenaRosterOrder+2], a
	ret


RemoveFromRoster:
	ld a, [wArenaRosterCountPlayer]
	cp 0
	ret z
	cp 1
	jr z, .removeOne
	cp 2
	jr z, .removeTwo
	cp 3
	jr z, .removeThree
	cp 4
	jr z, .removeFour
	cp 5
	jr z, .removeFive
	cp 6
	jr z, .removeSix
	jr .end
.removeOne
	; 1 sub
	ld a, [wArenaRosterOrder]
	and a, $7
	ld b, a
	ld a, [wArenaRosterOrder]
	sub b
	ld [wArenaRosterOrder], a
	jr .end
.removeTwo
	; 2 swap mask swap sub
	ld a, [wArenaRosterOrder]
	swap a
	and a, $7
	swap a
	ld b, a
	ld a, [wArenaRosterOrder]
	sub b
	ld [wArenaRosterOrder], a
	jr .end
.removeThree
	; 3 index+1 sub
	ld a, [wArenaRosterOrder+1]
	and a, $7
	ld b, a
	ld a, [wArenaRosterOrder+1]
	sub b
	ld [wArenaRosterOrder+1], a
	jr .end
.removeFour
	; 4 index+1 swap mask swap sub
	ld a, [wArenaRosterOrder+1]
	swap a
	and a, $7
	swap a
	ld b, a
	ld a, [wArenaRosterOrder+1]
	sub b
	ld [wArenaRosterOrder+1], a
	jr .end
.removeFive
	; 5 index+2 sub
	ld a, [wArenaRosterOrder+2]
	and a, $7
	ld b, a
	ld a, [wArenaRosterOrder+2]
	sub b
	ld [wArenaRosterOrder+2], a
	jr .end
.removeSix
	; 6 index+2 swap mask swap sub
	ld a, [wArenaRosterOrder+2]
	swap a
	and a, $7
	swap a
	ld b, a
	ld a, [wArenaRosterOrder+2]
	sub b
	ld [wArenaRosterOrder+2], a
.end
	ld a, [wArenaRosterCountPlayer]
	dec a
	ld [wArenaRosterCountPlayer], a
	ret
