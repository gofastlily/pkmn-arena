; calculates the difference |a-b|, setting carry flag if a<b
CalcDifference::
	sub b
	ret nc
	cpl
	add $1
	scf
	ret

MoveSprite::
MoveSprite_::
	ret

; divides [hDividend2] by [hDivisor2] and stores the quotient in [hQuotient2]
DivideBytes::
	push hl
	ld hl, hQuotient2
	xor a
	ld [hld], a
	ld a, [hld]
	and a
	jr z, .done
	ld a, [hli]
.loop
	sub [hl]
	jr c, .done
	inc hl
	inc [hl]
	dec hl
	jr .loop
.done
	pop hl
	ret
