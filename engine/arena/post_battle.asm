; X Draw trainer sprite
; X Draw small Pokémon sprites
; X Draw mini health bars
; Animate health bars
; Show fainted Pokémon differently
; Win/Lose text
; Return to main menu, not SoftReset


ArenaPostBattle:
	call ClearScreen
	farcall LoadMonPartySpriteGfxWithLCDDisabled ; load pokemon icon graphics
	call ArenaPostBattleShowPlayerTeam
	; call ArenaPostBattleShowEnemyTeam  ; Replicate Trainer Card for drawing to background
	call WaitForButtonPressAB
	ret


ArenaPostBattleShowPlayerTeam:
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

	xor a
	ld [wMonDataLocation], a

	call ArenaPostBattleSetupMon
	ld a, [wPartySpecies]
	ld [wcf91], a
	hlcoord 8, 4
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wPartyCount]
	cp 1
	jp z, .endParty

	ld a, 1
	call ArenaPostBattleSetupMon
	ld a, [wPartySpecies + 1]
	ld [wcf91], a
	hlcoord 11, 4
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wPartyCount]
	cp 2
	jp z, .endParty

	ld a, 2
	call ArenaPostBattleSetupMon
	ld a, [wPartySpecies + 2]
	ld [wcf91], a
	hlcoord 14, 4
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wPartyCount]
	cp 3
	jp z, .endParty

	ld a, 3
	call ArenaPostBattleSetupMon
	ld a, [wPartySpecies + 3]
	ld [wcf91], a
	hlcoord 8, 7
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wPartyCount]
	cp 4
	jp z, .endParty

	ld a, 4
	call ArenaPostBattleSetupMon
	ld a, [wPartySpecies + 4]
	ld [wcf91], a
	hlcoord 11, 7
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wPartyCount]
	cp 5
	jp z, .endParty

	ld a, 5
	call ArenaPostBattleSetupMon
	ld a, [wPartySpecies + 5]
	ld [wcf91], a
	hlcoord 14, 7
	call ArenaPostBattleDrawMonHP

.endParty
	ret


ArenaPostBattleShowEnemyTeam:
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

	ld a, 1
	ld [wMonDataLocation], a

	xor a
	call ArenaPostBattleSetupMon
	ld a, [wEnemyPartySpecies]
	ld [wcf91], a
	hlcoord 2, 13
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 1
	jp z, .endParty

	ld a, 1
	call ArenaPostBattleSetupMon
	ld a, [wEnemyPartySpecies]
	ld [wcf91], a
	hlcoord 5, 13
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 2
	jp z, .endParty

	ld a, 2
	call ArenaPostBattleSetupMon
	ld a, [wEnemyPartySpecies]
	ld [wcf91], a
	hlcoord 8, 13
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 3
	jp z, .endParty

	ld a, 3
	call ArenaPostBattleSetupMon
	ld a, [wEnemyPartySpecies]
	ld [wcf91], a
	hlcoord 2, 16
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 4
	jp z, .endParty

	ld a, 4
	call ArenaPostBattleSetupMon
	ld a, [wEnemyPartySpecies]
	ld [wcf91], a
	hlcoord 5, 16
	call ArenaPostBattleDrawMonHP
	; Check for end of party
	ld a, [wEnemyPartyCount]
	cp 5
	jp z, .endParty

	ld a, 5
	call ArenaPostBattleSetupMon
	ld a, [wEnemyPartySpecies]
	ld [wcf91], a
	hlcoord 8, 16
	call ArenaPostBattleDrawMonHP

.endParty
	ret


ArenaPostBattleSetupMon:
	ld [wArenaBattleTempCpuRosterIndex], a
	ld [wWhichPokemon], a
	ldh [hPartyMonIndex], a
	call LoadMonData
	farcall ArenaWriteMonPartySpriteOAMByPartyIndex
	ret


ArenaPostBattleDrawMonHP:
	predef DrawHPMini
	ld hl, wPlayerHPBarColor
	call GetBattleHealthBarColor
	ret


; AnnounceWinner:
; 	; Check if the player won the battle
; 	ld a, [wBattleResult]
; 	cp a, $00
; 	jr nz, .playerLost
; 	; Player Won
; 	call ShowPlayerTeam
; 	jr .endAnnounce
; .playerLost
; 	; Enemy Won
; 	call ShowEnemyTeam
; .endAnnounce
; 	call WaitForButtonPressAB
; 	ret
