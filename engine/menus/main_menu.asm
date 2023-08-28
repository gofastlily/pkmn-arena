MainMenu:
; Check save file
	call InitOptions
	xor a
	ld [wOptionsInitialized], a
	inc a
	ld [wSaveFileStatus], a
	call CheckForPlayerNameInSRAM
	jr nc, .mainMenuLoop

	predef LoadSAV

.mainMenuLoop
	ld c, 20
	call DelayFrames
	xor a ; LINK_STATE_NONE
	ld [wLinkState], a
	ld hl, wPartyAndBillsPCSavedMenuItem
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wDefaultMap], a
	ld hl, wd72e
	res 6, [hl]

	ld a, [wSaveFileStatus]
	cp 1
	jp z, .tallerMenu
	ld a, 6
	ld [wMenuHeight], a
	jp .setMenuWidth
.tallerMenu
	ld a, 4
	ld [wMenuHeight], a
.setMenuWidth
	ld a, 13
	ld [wMenuWidth], a

.menuLoop
	call ClearScreen

	ld hl, .emptyString
	ld a, h
	ld [wMenuExtraText], a
	ld a, l
	ld [wMenuExtraText + 1], a

	ld a, 14
	ld [wMenuExtraCoords], a
	ld a, 17
	ld [wMenuExtraCoords + 1], a

	ld hl, MainMenuChoicesList
	call MenuCore
	jp .menuLoop

.emptyString
	db "@"


MainMenuChoicesList:
	menu_choice Determine_MainMenuChoice_Continue, Action_MainMenuChoices_Continue, Text_MainMenuChoices_Continue
	menu_choice Determine_MainMenuChoice_NewGame,  Action_MainMenuChoices_NewGame,  Text_MainMenuChoices_NewGame
	menu_choice Determine_MainMenuChoice_Options,  Action_MainMenuChoices_Options,  Text_MainMenuChoices_Options
	dw MENU_CHOICES_LIST_END


Determine_MainMenuChoice_Continue:
	ld a, [wSaveFileStatus]
	cp 1
	ret z


Determine_MainMenuChoice_NewGame:
	jp AlwaysShowMenuItem


Determine_MainMenuChoice_Options:
	jp AlwaysShowMenuItem


Action_MainMenuChoices_Continue:
	call DisplayContinueGameInfo
.confirmContinueLoop
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit BIT_B_BUTTON, a
	jr nz, .bPressed
	bit BIT_A_BUTTON, a
	jr nz, .aPressed
	call DelayFrame
	jp .confirmContinueLoop
.aPressed
	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
	call ContinueGame
.bPressed
	ret


Action_MainMenuChoices_NewGame:
	call StartNewGame
	ret


Action_MainMenuChoices_Options:
	callfar DisplayOptionMenu
	ld a, 1
	ld [wOptionsInitialized], a
	ret


Text_MainMenuChoices_Continue:
	db "CONTINUE@"


Text_MainMenuChoices_NewGame:
	db "NEW GAME@"


Text_MainMenuChoices_Options:
	db "OPTIONS@"


InitOptions:
	ld a, TEXT_DELAY_FAST
	ld [wLetterPrintingDelayFlags], a
	ld a, TEXT_DELAY_MEDIUM
	ld [wOptions], a
	ld a, 64 ; audio?
	ld [wPrinterSettings], a
	ret


NotEnoughMemoryText:
	text_far _NotEnoughMemoryText
	text_end


StartNewGame:
	ld hl, wd732
	res 1, [hl]
	; fallthrough
StartNewGameDebug:
	farcall OakSpeech
	ld a, $8
	ld [wPlayerMovingDirection], a
	ld c, 20
	call DelayFrames


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
	ld a, [wEnteringCableClub]
	and a
	ret nz
	farjp EnterMap


ContinueGame:
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerDirection], a
	ld c, 10
	call DelayFrames
	ld a, [wNumHoFTeams]
	and a
	jp z, SpecialEnterMap
	ld a, [wCurMap] ; map ID
	cp HALL_OF_FAME
	jp nz, SpecialEnterMap
	xor a
	ld [wDestinationMap], a
	ld hl, wd732
	set 2, [hl] ; fly warp or dungeon warp
	call SpecialWarpIn
	jp SpecialEnterMap


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


DisplayOptionMenu:
	callfar DisplayOptionMenu_
	ret


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
