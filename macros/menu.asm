; function for checking item availability
; function when item is selected
; menu item text
; neat assert to check for conflicts

MACRO menu_choice
	dw \1
	dw \2
	dw \3
	assert LOW(\1) != $ff, "\1 is at $xxFF, conflicts with table terminator"
ENDM

MENU_CHOICES_LIST_END EQU $ffff
MENU_CAPACITY EQU 6
