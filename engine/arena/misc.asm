_hl_::
	jp hl


InitOptions:
	ld a, 1 ; no delay
	ld [wLetterPrintingDelayFlags], a
	ld a, %01000001  ; fast speed, animations off, set battle style
	ld [wOptions], a
	ld a, 64
	ld [wPrinterSettings], a
	; Skip nicknaming by default
	xor a
	set 7, a
	ld [wArenaOptions], a
	ret


PrintSaveScreenText:
	xor a
	ldh [hAutoBGTransferEnabled], a
	hlcoord 4, 0
	lb bc, 8, 14
	call TextBoxBorder
	call LoadTextBoxTilePatterns
	call UpdateSprites
	hlcoord 5, 2
	ld de, SaveScreenInfoText
	call PlaceString
	hlcoord 12, 2
	ld de, wPlayerName
	call PlaceString
	hlcoord 17, 4
	call PrintNumBadges
	hlcoord 16, 6
	call PrintNumOwnedMons
	hlcoord 13, 8
	call PrintPlayTime
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	ld c, 30
	jp DelayFrames


PrintNumBadges:
	push hl
	ld hl, wObtainedBadges
	ld b, $1
	call CountSetBits
	pop hl
	ld de, wNumSetBits
	lb bc, 1, 2
	jp PrintNumber


PrintNumOwnedMons:
	push hl
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	pop hl
	ld de, wNumSetBits
	lb bc, 1, 3
	jp PrintNumber


PrintPlayTime:
	ld de, wPlayTimeHours
	lb bc, 1, 3
	call PrintNumber
	ld [hl], $6d
	inc hl
	ld de, wPlayTimeMinutes
	lb bc, LEADING_ZEROES | 1, 2
	jp PrintNumber


SaveScreenInfoText:
	db   "PLAYER"
	next "BADGES    "
	next "#DEX    "
	next "TIME@"


CheckForPlayerNameInSRAM:
	; Check if the player name data in SRAM has a string terminator character
	; (indicating that a name may have been saved there) and return whether it does
	; in carry.
    ld a, SRAM_ENABLE
    ld [MBC1SRamEnable], a
    ld a, $1
    ld [MBC1SRamBankingMode], a
    ld [MBC1SRamBank], a
    ld b, NAME_LENGTH
    ld hl, sPlayerName
.loop
    ld a, [hli]
    cp "@"
    jr z, .found
    dec b
    jr nz, .loop
; not found
    xor a
    ld [MBC1SRamEnable], a
    ld [MBC1SRamBankingMode], a
    and a
    ret
.found
    xor a
    ld [MBC1SRamEnable], a
    ld [MBC1SRamBankingMode], a
    scf
    ret


; enter map after using a special warp or loading the game from the main menu
SpecialEnterMap::
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyHeld], a
	ldh [hJoy5], a
	ld [wd72d], a
	ld hl, wd732
	set 0, [hl] ; count play time
	call ResetPlayerSpriteData
	ld c, 20
	call DelayFrames
	call Func_5cc1
	ld a, [wEnteringCableClub]
	and a
	ret nz
	jp EnterMap


Func_5cc1:
; unused?
	ld a, $6d
	cp $80
	ret c ; will always be executed
	ld hl, NotEnoughMemoryText
	call PrintText
	ret


NotEnoughMemoryText:
	text_far _NotEnoughMemoryText
	text_end


DisplayContinueGameInfo:
	xor a
	ldh [hAutoBGTransferEnabled], a
	hlcoord 4, 7
	lb bc, 8, 14
	call TextBoxBorder
	hlcoord 5, 9
	ld de, SaveScreenInfoText
	call PlaceString
	hlcoord 12, 9
	ld de, wPlayerName
	call PlaceString
	hlcoord 17, 11
	call PrintNumBadges
	hlcoord 16, 13
	call PrintNumOwnedMons
	hlcoord 13, 15
	call PrintPlayTime
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ld c, 30
	jp DelayFrames


ShowTeams:
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


AnnounceWinner:
	call ClearScreen
	; Check if the player won the battle
	ld a, [wBattleResult]
	cp a, $00
	jr nz, .playerLost
	; Player Won
	call ShowPlayerTeam
	jr .endAnnounce
.playerLost
	; Enemy Won
	call ShowEnemyTeam
.endAnnounce
	call WaitForButtonPressAB
	ret


WaitForButtonPressAB:
.waitForButtonPress
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	and A_BUTTON | B_BUTTON
	jr z, .waitForButtonPress
	ret
