MenuCore:
	; menu options are passed in through hl
.initMenuCore
	push hl

	ld hl, wd72e
	res 6, [hl]
	call ClearScreen
	call RunDefaultPaletteCommand
	call LoadTextBoxTilePatterns
	call LoadFontTilePatterns
	ld hl, wd730
	set 6, [hl]

	ld hl, wd730
	res 6, [hl]
	call UpdateSprites
	xor a
	ld [wMenuChoicesCount], a
	ld [wOptionsCursorLocation], a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld [wMenuJoypadPollCount], a
	inc a
	ld [wTopMenuItemX], a
	inc a
	ld [wTopMenuItemY], a
	ld a, A_BUTTON | B_BUTTON | START
	ld [wMenuWatchedKeys], a
	
	pop hl

	call DetermineMenuOptions
	call DrawMenu
	call DrawMenuExtra

.mainMenuLoop
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit BIT_B_BUTTON, a
	jr nz, .bPressed
	bit BIT_A_BUTTON, a
	jr nz, .aPressed
	call MenuChoicesControl
	ld a, [wMenuChoicesCount]
	call UpdateMenuCursorPosition
	call DelayFrame
	jr .mainMenuLoop
.aPressed
	call CallMenuAction
	ld a, CHOSE_MENU_ITEM
	ld [wMenuExitMethod], a
	call ClearMenuExtra
	ret
.bPressed
	ld a, CANCELLED_MENU
	ld [wMenuExitMethod], a
	call ClearMenuExtra
	ret


DetermineMenuOptions:
	; Loop through a list of menu choices in hl

.determineMenuItemsLoop
	ld a, [hl]
	cp $ff  ; Why doesn't this work with MENU_CHOICES_LIST_END?
	jp z, .breakDetermineMenuItemsLoop
	; Determine if the menu item should be displayed
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	pop hl
	jr z, .doNotAdd

	; Add action to [wMenuActionsItems]
	push hl
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wMenuActionsItems
	call AppendItemToMenuChoices
	pop hl

	; Add text to [wMenuTextItems]
	push hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wMenuTextItems
	call AppendItemToMenuChoices
	pop hl

	; Increment the count
	ld a, [wMenuChoicesCount]
	inc a  ; increment the number of items in the menu
	ld [wMenuChoicesCount], a

.doNotAdd
	ld bc, 6  ; Length of menu_choice macro in bytes
	add hl, bc
	jp .determineMenuItemsLoop

.breakDetermineMenuItemsLoop
	ret


AppendItemToMenuChoices:
	; de: wram target
	; hl: choice list
	ld a, d
	ld d, h
	ld h, a
	ld a, e
	ld e, l
	ld l, a
	; de: choice list
	; hl: wram target
	ld a, [wMenuChoicesCount]  ; the number of items will be the index of the new item
	add a
	ld c, a
	ld b, 0
	add hl, bc  ; hl = address to store the item
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ret


MenuChoicesControl:
	ld hl, wOptionsCursorLocation
	ldh a, [hJoy5]
	cp D_DOWN
	jr z, .pressedDown
	cp D_UP
	jr z, .pressedUp
	and a
	ret
.pressedDown
	ld b, [hl]
	ld a, [wMenuChoicesCount]
	dec a
	cp b
	jr nz, .doNotWrapAround
	ld [hl], $0
	scf
	ret
.doNotWrapAround
	inc [hl]
	scf
	ret
.pressedUp
	ld a, [hl]
	and a
	jr nz, .regularDecrement
	ld a, [wMenuChoicesCount]
	ld [hl], a
.regularDecrement
	dec [hl]
	scf
	ret

	
UpdateMenuCursorPosition:
	hlcoord 1, 1
	ld de, SCREEN_WIDTH
	add a
	ld c, a
.loop
	ld [hl], " "
	add hl, de
	dec c
	jr nz, .loop
	hlcoord 1, 2
	ld bc, SCREEN_WIDTH * 2
	ld a, [wOptionsCursorLocation]
	call AddNTimes
	ld [hl], "▶"
	ret


DrawMenu:
	call DrawMenuBorder
	call DrawMenuItems
	ret


DrawMenuBorder:
	; Draw a static menu height by default
	ld a, [wMenuHeight]
	cp 0
	jp nz, .skipDynamicHeight

	; Draw a dynamic menu height
	ld a, [wMenuChoicesCount]
	; Double the menu item count and add one
	; because we want padding around each item
	add a
	inc a
.skipDynamicHeight
	
	hlcoord 0, 0
	ld b, a
	ld a, [wMenuWidth]
	ld c, a
	call TextBoxBorder
	ret


DrawMenuItems:
	ld a, [wMenuChoicesCount]
	ld d, 0
.loop
	cp a, 0
	jp z, .break
	call DrawMenuChoiceText
	dec a
	inc d
	jp .loop
.break
	ret


DrawMenuChoiceText:
	push af
	push de
	push hl
	ld a, d
	add a
	ld c, a
	ld b, 0
	ld hl, wMenuTextItems
	add hl, bc
	ld c, d
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	call SetMenuHLCoord
	pop de
	call PlaceString
	pop hl
	pop de
	pop af
	ret


SetMenuHLCoord:
	; Recreate hlcoords with variable y support
	; y is c
	ld a, c
	add a
	inc a
	inc a
	; x is hardcoded
	; multiply y by SCREEN_WITH
	ld b, a
rept SCREEN_WIDTH - 1
	add a, b
endr
	; add to x
	add a, 2
	; add to wTileMap and load into hl
	ld hl, wTileMap
	ld e, a
	ld d, 0
	add hl, de
	ret


CallMenuAction:
	push af
	push de
	push hl
	ld a, [wOptionsCursorLocation]
	add a
	ld c, a
	ld b, 0
	ld hl, wMenuActionsItems
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld d, h
	ld e, l
	call _hl_
	pop hl
	pop de
	pop af
	ret


_hl_::
	jp hl


DrawMenuExtra:
	; check for $FF in wMenuExtraText + 1
	ld a, [wMenuExtraText + 1]
	cp $FF
	ret z

	; Load wMenuExtraCoords into HL
	; hlcoord [wMenuExtraCoords], [wMenuExtraCoords + 1]
	; start with the y coordinate
	ld a, [wMenuExtraCoords + 1]
	ld b, a
rept (SCREEN_WIDTH / 4) - 1
	add a, b
endr
	sla a
	sla a
	ld b, a
	ld a, 0
	adc a
	ld c, a
	; add the x coordinate
	ld a, [wMenuExtraCoords]
	add b
	jr nc, .next
	inc c
.next
	; add to wTileMap and load into hl
	ld hl, wTileMap
	ld e, a
	ld d, c
	add hl, de

	; Load wMenuExtraText into DE
	ld a, [wMenuExtraText]
	ld d, a
	ld a, [wMenuExtraText + 1]
	ld e, a
	call PlaceString
	ret


ClearMenuExtra:
	ld a, $FF
	ld [wMenuExtraText], a
	ld a, $FF
	ld [wMenuExtraText + 1], a

	ld a, 0
	ld [wMenuExtraCoords], a
	ld a, 0
	ld [wMenuExtraCoords + 1], a
	ret


AlwaysShowMenuItem:
	xor a
	cp 1
	ret


InvertZeroFlag:
    ld a, 0
    jr nz, .done
    inc a
.done
    and a
    ret
