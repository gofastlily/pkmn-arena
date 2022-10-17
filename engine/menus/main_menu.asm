MainMenu:
	call InitOptions
	; Check save file
	; Needs to be fixed
	xor a
	ld [wOptionsInitialized], a
	inc a
	ld [wSaveFileStatus], a
	call CheckForPlayerNameInSRAM
	jr nc, .loadSkip
	predef LoadSAV

.loadSkip
	ld c, 1
	call DelayFrames
	xor a ; LINK_STATE_NONE
	ld [wLinkState], a
	ld hl, wPartyAndBillsPCSavedMenuItem
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wDefaultMap], a

.menuLoop
	ld hl, MainMenuChoicesList
	call ArenaMenu
	jp .menuLoop
	


MainMenuChoicesList:
	arena_menu_choice Determine_MainMenuChoice_Continue,   Action_MainMenuChoices_Continue,   Text_MainMenuChoices_Continue
	arena_menu_choice Determine_MainMenuChoice_NewGame,    Action_MainMenuChoices_NewGame,    Text_MainMenuChoices_NewGame
	arena_menu_choice Determine_MainMenuChoice_Options,    Action_MainMenuChoices_Options,    Text_MainMenuChoices_Options
	dw ARENA_MENU_CHOICES_LIST_END


Determine_MainMenuChoice_Continue:
	; Change to displaying Continue only when the player is mid-run
	ld a, [wSaveFileStatus]
	cp 1
	ret


Determine_MainMenuChoice_NewGame:
	xor a
	cp 1
	ret


Determine_MainMenuChoice_Options:
	xor a
	cp 1
	ret


Action_MainMenuChoices_Continue:
	; Needs to be refactored
	call DisplayContinueGameInfo
	ld a, [wMenuExitMethod]
	cp CANCELLED_MENU
	ret z

	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
	ld c, 10
	call DelayFrames

	jp SpecialEnterMap


Action_MainMenuChoices_NewGame:
IF DEF(_DEBUG)
	callfar StartNewGameDebug
ELSE
	callfar StartNewGame
ENDC
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
