ArenaReadCpuTrainerParty:
	; Manually set level for whole team
	ld a, 50
	ld [wCurEnemyLVL], a

	call ArenaLoadTrainerData
	ld a, h
	ld [wArenaTrainerTeamLocation], a
	ld a, l
	ld [wArenaTrainerTeamLocation+1], a

	xor a
	ld [wArenaBattleTempCpuRosterIndex], a
	
	; Load based on order given in
	; [wArenaRosterOrder]
	; $10, $32, $54
	; eg.
	; $31, $24, $05

.loadTrainerPartyLoop
	ld b, a
	ld a, [wArenaRosterTargetCount]
	cp b
	jp z, .endLoadTrainerPartyLoop
	
	ld a, [wArenaBattleTempCpuRosterIndex]
	call ArenaGetValueFromRosterCpu
	ld [wArenaBattleTempCpuRosterValue], a

	ld b, a
	ld a, [wArenaTrainerTeamLocation]
	ld h, a
	ld a, [wArenaTrainerTeamLocation+1]
	ld l, a
	call ArenaLoadTrainerParty
	call ArenaLoadAdditionalMoveData

	ld a, [wArenaBattleTempCpuRosterIndex]
	inc a
	ld [wArenaBattleTempCpuRosterIndex], a

	jp .loadTrainerPartyLoop

.endLoadTrainerPartyLoop
	ret


ArenaLoadTrainerData:
	; set [wEnemyPartyCount] to 0, [wEnemyPartySpecies] to FF
	; XXX first is total enemy pokemon?
	; XXX second is species of first pokemon?
	ld hl, wEnemyPartyCount
	xor a
	ld [hli], a
	dec a
	ld [hl], a

	; get the pointer to trainer data for this class
	ld a, [wTrainerClass] ; get trainer class
	dec a
	add a
	ld hl, TrainerDataPointers
	ld c, a
	ld b, 0
	add hl, bc ; hl points to trainer class
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wTrainerNo]
	ld b, a
	; At this point b contains the trainer number,
	; and hl points to the trainer class.
	; Our next task is to iterate through the trainers,
	; decrementing b each time, until we get to the right one.
.outer
	dec b
	jr z, .IterateTrainer
.inner
	ld a, [hli]
	and a
	jr nz, .inner
	jr .outer
.IterateTrainer
	ret


ArenaLoadTrainerParty:
	inc hl  ; skip pokemon level value
	inc b
.loopTrainerPokemon
	; loop b times
	; loop hl inc as per current index in opponent roster
	inc hl
	dec b
	ld a, b
	cp 0
	jp nz, .loopTrainerPokemon
	; actual logic to add species to enemy team
	ld a, [hl]
	ld [wcf91], a ; write species somewhere (XXX why?)
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	push hl
	call AddPartyMon
	pop hl
	; end add to enemy team logic
	ret


ArenaLoadAdditionalMoveData:
; does the trainer have additional move data?
	ld a, [wTrainerClass]
	ld b, a
	ld a, [wTrainerNo]
	ld c, a
	ld hl, SpecialTrainerMoves

	; Go to next trainer's moves
.loopAdditionalMoveData
	ld a, [hli]  ; a holds trainer class from data table entry
	cp $ff
	jr z, .FinishUp
	cp b  ; b holds the opponent trainer class
	jr nz, .nextTrainer  ; this jump will be taken if b is not equal to a
	ld a, [hli]
	cp c  ; c holds the trainer number
	jr nz, .nextTrainer  ; this jump will be taken if b is not equal to a
	ld d, h
	ld e, l

.writeAdditionalMoveDataLoop
	ld a, [de]
	ld b, a
	inc de

	; finish looping through moves
	and a  ; cp 0
	jp z, .FinishUp

	; loop to the next move
	ld a, [wArenaBattleTempCpuRosterValue]
	inc a
	inc a
	cp b
	jp nz, .nextMove

	; Increment to the correct move slots
	ld a, [wArenaBattleTempCpuRosterIndex]
	ld hl, wEnemyMon1Moves
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes

	; write the desired move
	ld a, [de]
	inc de
	dec a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [de]
	inc de
	ld [hl], a
	jr .writeAdditionalMoveDataLoop

	; loop to next trainer
.nextTrainer
	ld a, [hli]
	and a
	jr nz, .nextTrainer
	jr .loopAdditionalMoveData

.nextMove
	inc de
	inc de
	jr .writeAdditionalMoveDataLoop

.FinishUp
	ret


ArenaGetValueFromRosterCpu:
	; get a value from the roster by index (a)
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
	ld a, [wArenaRosterOrderCpu]
	and $7
	ret
.indexOne
	ld a, [wArenaRosterOrderCpu]
	swap a
	and $7
	ret
.indexTwo
	ld a, [wArenaRosterOrderCpu+1]
	and $7
	ret
.indexThree
	ld a, [wArenaRosterOrderCpu+1]
	swap a
	and $7
	ret
.indexFour
	ld a, [wArenaRosterOrderCpu+2]
	and $7
	ret
.indexFive
	ld a, [wArenaRosterOrderCpu+2]
	swap a
	and $7
	ret
