ShowTeams::
	call ClearScreen
	call ShowPlayerTeam
	call ShowEnemyTeam
	ret


ShowPlayerTeam:
	hlcoord 0, 0
	ld b, 7
	ld c, 18
	call TextBoxBorder

	ld de, RedPicFront
	lb bc, BANK(RedPicFront), $00
	call DisplayPlayerPreviewPic

	hlcoord 1, 7
	ld de, BlankTrainerNameText
	call PlaceString
	ld de, wPlayerName
	call PlaceString

	hlcoord 9, 1
	ld de, wPartyMon1Nick
	call PlaceString
	; Check for end of party
	ld a, [wPartyCount]
	cp 1
	jp z, .endParty

	hlcoord 9, 2
	ld de, wPartyMon2Nick
	call PlaceString
	; Check for end of party
	ld a, [wPartyCount]
	cp 2
	jp z, .endParty

	hlcoord 9, 3
	ld de, wPartyMon3Nick
	call PlaceString
	; Check for end of party
	ld a, [wPartyCount]
	cp 3
	jp z, .endParty

	hlcoord 9, 4
	ld de, wPartyMon4Nick
	call PlaceString
	; Check for end of party
	ld a, [wPartyCount]
	cp 4
	jp z, .endParty

	hlcoord 9, 5
	ld de, wPartyMon5Nick
	call PlaceString
	; Check for end of party
	ld a, [wPartyCount]
	cp 5
	jp z, .endParty

	hlcoord 9, 6
	ld de, wPartyMon6Nick
	call PlaceString
	; Check for end of party
	ld a, [wPartyCount]
	cp 6
	jp z, .endParty

.endParty
	ret


ShowEnemyTeam:
	hlcoord 0, 9
	ld b, 7
	ld c, 18
	call TextBoxBorder

	ld de, Rival1Pic
	lb bc, BANK(Rival1Pic), $00
	call DisplayEnemyPreviewPic

	hlcoord 12, 16
	ld de, BlankTrainerNameText
	call PlaceString
	ld de, wRivalName
	call PlaceString

	hlcoord 1, 10
	ld a, [wEnemyMon1]
	call DrawEnemyMonName
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 1
	jp z, .endParty

	hlcoord 1, 11
	ld a, [wEnemyMon2]
	call DrawEnemyMonName
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 2
	jp z, .endParty

	hlcoord 1, 12
	ld a, [wEnemyMon3]
	call DrawEnemyMonName
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 3
	jp z, .endParty

	hlcoord 1, 13
	ld a, [wEnemyMon4]
	call DrawEnemyMonName
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 4
	jp z, .endParty

	hlcoord 1, 14
	ld a, [wEnemyMon5]
	call DrawEnemyMonName
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 5
	jp z, .endParty

	hlcoord 1, 15
	ld a, [wEnemyMon6]
	call DrawEnemyMonName

.endParty
	ret


DisplayPlayerPreviewPic:
; b = bank
; de = address of compressed pic
; c: 0 = centred, non-zero = upper-right
	push bc
	ld a, b
	call UncompressSpriteFromDE
	ld a, $0
	call SwitchSRAMBankAndLatchClockData
	ld hl, sSpriteBuffer1
	ld de, sSpriteBuffer0
	ld bc, $310
	call CopyData
	call PrepareRTCDataAndDisableSRAM
	ld de, vBackPic
	call InterlaceMergeSpriteBuffers
	pop bc
	hlcoord 1, 1
	ld a, $31
	ldh [hStartTileID], a
	predef_jump CopyUncompressedPicToTilemap
	ret


DisplayEnemyPreviewPic:
; b = bank
; de = address of compressed pic
; c: 0 = centred, non-zero = upper-right
	push bc
	ld a, b
	call UncompressSpriteFromDE
	ld a, $0
	call SwitchSRAMBankAndLatchClockData
	ld hl, sSpriteBuffer1
	ld de, sSpriteBuffer0
	ld bc, $310
	call CopyData
	call PrepareRTCDataAndDisableSRAM
	ld de, vFrontPic
	call InterlaceMergeSpriteBuffers
	pop bc
	hlcoord 12, 10
	xor a
	ldh [hStartTileID], a
	predef_jump CopyUncompressedPicToTilemap
	ret


DrawEnemyMonName:
	ld [wd11e], a
	call GetMonName
	ld de, wcd6d
	call PlaceString
	ret


BlankTrainerNameText:
	db "       @"


WaitForButtonPressAB:
.waitForButtonPress
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	and A_BUTTON | B_BUTTON
	jr z, .waitForButtonPress
	ret
