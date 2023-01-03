TeamSelectionLoadPokeball:
	ld a, $C0
	ld [hl], a
	ret


TeamSelectionLoadEmptyPokeball:
	ld a, $C3
	ld [hl], a
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
	hlcoord 14, 7
	call TeamSelectionLoadEmptyPokeball
	hlcoord 6, 16
	call TeamSelectionLoadEmptyPokeball
.rosterFive
	hlcoord 13, 7
	call TeamSelectionLoadEmptyPokeball
	hlcoord 5, 16
	call TeamSelectionLoadEmptyPokeball
.rosterFour
	hlcoord 12, 7
	call TeamSelectionLoadEmptyPokeball
	hlcoord 4, 16
	call TeamSelectionLoadEmptyPokeball
.rosterThree
	hlcoord 11, 7
	call TeamSelectionLoadEmptyPokeball
	hlcoord 3, 16
	call TeamSelectionLoadEmptyPokeball
.rosterTwo
	hlcoord 10, 7
	call TeamSelectionLoadEmptyPokeball
	hlcoord 2, 16
	call TeamSelectionLoadEmptyPokeball
.rosterOne
	hlcoord 9, 7
	call TeamSelectionLoadEmptyPokeball
	hlcoord 1, 16
	call TeamSelectionLoadEmptyPokeball
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
	hlcoord 14, 7
	call TeamSelectionLoadPokeball
.playerRosterFive
	hlcoord 13, 7
	call TeamSelectionLoadPokeball
.playerRosterFour
	hlcoord 12, 7
	call TeamSelectionLoadPokeball
.playerRosterThree
	hlcoord 11, 7
	call TeamSelectionLoadPokeball
.playerRosterTwo
	hlcoord 10, 7
	call TeamSelectionLoadPokeball
.playerRosterOne
	hlcoord 9, 7
	call TeamSelectionLoadPokeball
	ret


TeamSelectionEnemyPartyPokeballs:
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
	hlcoord 6, 16
	call TeamSelectionLoadPokeball
.enemyRosterFive
	hlcoord 5, 16
	call TeamSelectionLoadPokeball
.enemyRosterFour
	hlcoord 4, 16
	call TeamSelectionLoadPokeball
.enemyRosterThree
	hlcoord 3, 16
	call TeamSelectionLoadPokeball
.enemyRosterTwo
	hlcoord 2, 16
	call TeamSelectionLoadPokeball
.enemyRosterOne
	hlcoord 1, 16
	call TeamSelectionLoadPokeball
	ret


TeamSelectionPlayerTeamCallouts:
.clearCallouts
	ld c, 0
	call SetRosterNumberHLCoord
	ld [hl], " "
	ld c, 1
	call SetRosterNumberHLCoord
	ld [hl], " "
	ld c, 2
	call SetRosterNumberHLCoord
	ld [hl], " "
	ld c, 3
	call SetRosterNumberHLCoord
	ld [hl], " "
	ld c, 4
	call SetRosterNumberHLCoord
	ld [hl], " "
	ld c, 5
	call SetRosterNumberHLCoord
	ld [hl], " "
.calloutJumpTable
	ld a, [wArenaRosterCountPlayer]
	cp 1
	jr z, .playerRosterCalloutOne
	cp 2
	jr z, .playerRosterCalloutTwo
	cp 3
	jr z, .playerRosterCalloutThree
	cp 4
	jr z, .playerRosterCalloutFour
	cp 5
	jr z, .playerRosterCalloutFive
	cp 6
	jr z, .playerRosterCalloutSix
	ret
.playerRosterCalloutSix
	ld a, [wArenaRosterOrder+2]
	and $70
	swap a
	ld c, a
	call SetRosterNumberHLCoord
	ld [hl], "6"
.playerRosterCalloutFive
	ld a, [wArenaRosterOrder+2]
	and $7
	ld c, a
	call SetRosterNumberHLCoord
	ld [hl], "5"
.playerRosterCalloutFour
	ld a, [wArenaRosterOrder+1]
	and $70
	swap a
	ld c, a
	call SetRosterNumberHLCoord
	ld [hl], "4"
.playerRosterCalloutThree
	ld a, [wArenaRosterOrder+1]
	and $7
	ld c, a
	call SetRosterNumberHLCoord
	ld [hl], "3"
.playerRosterCalloutTwo
	ld a, [wArenaRosterOrder]
	and $70
	swap a
	ld c, a
	call SetRosterNumberHLCoord
	ld [hl], "2"
.playerRosterCalloutOne
	ld a, [wArenaRosterOrder]
	and $7
	ld c, a
	call SetRosterNumberHLCoord
	ld [hl], "1"
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

	; Draw pokéballs and callouts
	call TeamSelectionPlayerPartyPokeballs
	call TeamSelectionPlayerTeamCallouts
	call TeamSelectionEnemyPartyPokeballs

	callfar DelayFrame
	ld a, [wArenaRosterCountPlayer]
	ld b, a
	ld a, [wArenaRosterTargetCount]
	cp b
	jp nz, .pickRosterLoop

.rosterPromptLoop
	ld hl, IsThisTeamOkayText
	call PrintText
	hlcoord 14, 7
	lb bc, 8, 15
	xor a ; YES_NO_MENU
	ld [wTwoOptionMenuID], a
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID
	ld a, [wCurrentMenuItem]
	and a
	jp z, .endRosterPromptLoop

	ld a, [wArenaRosterOrder+2]
	and $7
	ld [wArenaRosterOrder+2], a
	ld a, [wArenaRosterCountPlayer]
	dec a
	ld [wArenaRosterCountPlayer], a
	callfar ShowTeams
	jp .pickRosterLoop

.endRosterPromptLoop

	call ShuffleOpponentRoster
	call LoadPlayerRoster
	ret


IsThisTeamOkayText:
	text_far _IsThisTeamOkayText
	text_end

_IsThisTeamOkayText::
	text "Is this team okay?"
	done


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
	bit BIT_SELECT, a
	jr nz, .selectPressed
	bit BIT_D_DOWN, a
	jr nz, .downPressed
	bit BIT_D_UP, a
	jr nz, .upPressed
	ret
.aPressed
	ld a, [wArenaRosterCursorLocationY]
	call AlreadyInRoster
	ret z
	call AddToRoster
	ret
.bPressed
	call RemoveFromRoster
	ret
.selectPressed
	call ShowStatus
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
	and $70
	add b
	ld [wArenaRosterOrder], a
	ret
.addTwo
	; 2 swap add swap
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder]
	and $7
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
	and $70
	add b
	ld [wArenaRosterOrder+1], a
	ret
.addFour
	; 4 index+1 swap add swap
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder+1]
	and $7
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
	and $70
	add b
	ld [wArenaRosterOrder+2], a
	ret
.addSix
	; 6 index+2 swap add swap
	ld a, [wArenaRosterCursorLocationY]
	ld b, a
	ld a, [wArenaRosterOrder+2]
	and $7
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
	ld a, [wArenaRosterOrder]
	and a, $70
	add $7
	ld [wArenaRosterOrder], a
	jr .end
.removeTwo
	ld a, [wArenaRosterOrder]
	and a, $7
	add $70
	ld [wArenaRosterOrder], a
	jr .end
.removeThree
	ld a, [wArenaRosterOrder+1]
	and a, $70
	add $7
	ld [wArenaRosterOrder+1], a
	jr .end
.removeFour
	ld a, [wArenaRosterOrder+1]
	and a, $7
	add $70
	ld [wArenaRosterOrder+1], a
	jr .end
.removeFive
	ld a, [wArenaRosterOrder+2]
	and a, $70
	add $7
	ld [wArenaRosterOrder+2], a
	jr .end
.removeSix
	ld a, [wArenaRosterOrder+2]
	and a, $7
	add $70
	ld [wArenaRosterOrder+2], a
.end
	ld a, [wArenaRosterCountPlayer]
	dec a
	ld [wArenaRosterCountPlayer], a
	ret


AlreadyInRoster:
	ld d, a

	ld a, [wArenaRosterOrder]
	and a, $7
	ld b, a
	ld a, d
	cp b
	jp z, .inRoster

	ld a, [wArenaRosterOrder]
	swap a
	and a, $7
	ld b, a
	ld a, d
	cp b
	jp z, .inRoster

	ld a, [wArenaRosterOrder+1]
	and a, $7
	ld b, a
	ld a, d
	cp b
	jp z, .inRoster

	ld a, [wArenaRosterOrder+1]
	swap a
	and a, $7
	ld b, a
	ld a, d
	cp b
	jp z, .inRoster

	ld a, [wArenaRosterOrder+2]
	and a, $7
	ld b, a
	ld a, d
	cp b
	jp z, .inRoster

	ld a, [wArenaRosterOrder+2]
	swap a
	and a, $7
	ld b, a
	ld a, d
	cp b
	jp z, .inRoster

.notInRoster
	xor a
	jr .end
.inRoster
	ld a, 1
.end
	cp 1
	ret


SetValueToRosterCpu:
	; set a value (e) from the roster by index (a)
	cp 0
	jp z, .indexZero
	cp 1
	jp z, .indexOne
	cp 2
	jp z, .indexTwo
	cp 3
	jp z, .indexThree
	cp 4
	jp z, .indexFour
	cp 5
	jp z, .indexFive
	ret
.indexZero
	; 0 add
	ld a, [wArenaRosterOrderCpu]
	and $70
	add e
	ld [wArenaRosterOrderCpu], a
	ret
.indexOne
	; 1 swap add swap
	ld a, [wArenaRosterOrderCpu]
	and $7
	swap a
	add e
	swap a
	ld [wArenaRosterOrderCpu], a
	ret
.indexTwo
	; 2 index+1 add
	ld a, [wArenaRosterOrderCpu+1]
	and $70
	add e
	ld [wArenaRosterOrderCpu+1], a
	ret
.indexThree
	; 3 index+1 swap add swap
	ld a, [wArenaRosterOrderCpu+1]
	and $7
	swap a
	add e
	swap a
	ld [wArenaRosterOrderCpu+1], a
	ret
.indexFour
	; 4 index+2 add
	ld a, [wArenaRosterOrderCpu+2]
	and $70
	add e
	ld [wArenaRosterOrderCpu+2], a
	ret
.indexFive
	; 5 index+2 swap add swap
	ld a, [wArenaRosterOrderCpu+2]
	and $7
	swap a
	add e
	swap a
	ld [wArenaRosterOrderCpu+2], a
	ret


SetRosterNumberHLCoord:
	; Recreate hlcoords with variable y support
	; y is c
	ld a, c
	inc a
	; x is hardcoded
	; multiply y by SCREEN_WIDTH
	ld b, a
rept SCREEN_WIDTH - 1
	add a, b
endr
	; add to x
	add a, 7
	; load wTileMap into hl and add the y value
	ld hl, wTileMap
	ld e, a
	ld d, 0
	add hl, de
	ret


SwapRosterOrderCpu:
	; wArenaRosterOrderCpu = arr
	; b = i
	; c = j
	; arr[i], arr[j] = arr[j], arr[i]
	ld a, b
	callfar ArenaGetValueFromRosterCpu
	ld d, a
	ld a, c
	callfar ArenaGetValueFromRosterCpu
	ld e, a
	ld a, b
	call SetValueToRosterCpu
	ld a, d
	ld e, a
	ld a, c
	call SetValueToRosterCpu
	ret


ShowStatus:
	ld a, [wArenaRosterCursorLocationY]
	ld [wWhichPokemon], a
	call SaveScreenTilesToBuffer1
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	predef StatusScreen
	predef StatusScreen2
	call LoadScreenTilesFromBuffer1
	call ReloadTilesetTilePatterns
	call RunDefaultPaletteCommand
	call LoadGBPal
	ret


LoadPlayerRoster:
	xor a
	ld [wWhichPokemon], a
REPT 6
	call ForceDeposit
ENDR

	ld a, [wArenaRosterOrder]
	and $7
	ld [wWhichPokemon], a
	call ForceWithdraw
	ld a, [wArenaRosterTargetCount]
	cp 1
	jp z, .end

	ld a, [wArenaRosterOrder]
	swap a
	and $7
	ld [wWhichPokemon], a
	call ForceWithdraw
	ld a, [wArenaRosterTargetCount]
	cp 2
	jp z, .end

	ld a, [wArenaRosterOrder+1]
	and $7
	ld [wWhichPokemon], a
	call ForceWithdraw
	ld a, [wArenaRosterTargetCount]
	cp 3
	jp z, .end

	ld a, [wArenaRosterOrder+1]
	swap a
	and $7
	ld [wWhichPokemon], a
	call ForceWithdraw
	ld a, [wArenaRosterTargetCount]
	cp 4
	jp z, .end

	ld a, [wArenaRosterOrder+2]
	and $7
	ld [wWhichPokemon], a
	call ForceWithdraw
	ld a, [wArenaRosterTargetCount]
	cp 5
	jp z, .end

	ld a, [wArenaRosterOrder+2]
	swap a
	and $7
	ld [wWhichPokemon], a
	call ForceWithdraw

.end
	ret


ForceDeposit:
	; ld [wWhichPokemon], 0
	ld a, PARTY_TO_BOX
	ld [wMoveMonType], a
	call MoveMon
	xor a
	ld [wRemoveMonFromBox], a
	call RemovePokemon
	ret


ForceWithdraw:
	; ld [wWhichPokemon], 0
	xor a  ; BOX_TO_PARTY
	ld [wMoveMonType], a
	call MoveMon
	ret


ShuffleOpponentRoster:
	; Prepopulate list for opponent team
	ld a, $10
	ld [wArenaRosterOrderCpu], a
	ld a, $32
	ld [wArenaRosterOrderCpu+1], a
	ld a, $54
	ld [wArenaRosterOrderCpu+2], a
	; Shuffle opponent team selection
	ld a, [wArenaBattleTempCpuRosterIndex]
.rosterRandLoop
	ld b, a
	ld a, 5
	call RandomRange
	cp b
	jr z, .indicesAreEqual
	ld c, a
	call SwapRosterOrderCpu
.indicesAreEqual
	ld a, [wArenaBattleTempCpuRosterIndex]
	inc a
	ld [wArenaBattleTempCpuRosterIndex], a
	cp 5
	jr c, .rosterRandLoop
