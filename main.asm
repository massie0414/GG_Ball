.memorymap
defaultslot 0
	slotsize $4000
	slot 0 $0000
	slotsize $4000
	slot 1 $4000
	slotsize $4000
	slot 2 $8000
	slotsize $1d00
	slot 3 $c000
	slotsize $100
	slot 4 $dd00
.endme

.ROMBANKMAP
	BANKSTOTAL 4
	BANKSIZE $4000
	BANKS 4
.ENDRO

.define BANK_SWITCH $ffff

.sdsctag 0.01, "Ball", "Release note.", "massie"
.smstag

.BANK 0 SLOT 0

.org $0000
.section "start" force
	di			; disable interrupts.		���荞�݂𖳌��ɂ��܂��B
	im 1			; interrupt mode 1.			���荞�݃��[�h1�B
	ld sp,$dff0		; default stack pointer address.	�f�t�H���g�̃X�^�b�N�|�C���^�A�h���X�B
	jp inigam
.ends

.orga $0038			; frame interrupt address. 			�t���[�����荞�݃A�h���X�B
.section "vBlankVector" force
	ex af,af'		; save accumulator in its shadow reg.	�A�L�������[�^���V���h�E���W�X�^�ɕۑ����܂��B
	in a,$bf		; get vdp status / satisfy interrupt.	vdp�X�e�[�^�X���擾/���荞�݂𖞂����܂��B
	ld (status),a		; save vdp status in ram. 			RAM��vdp�X�e�[�^�X��ۑ����܂��B
	ld a,1			; load accumulator with raised flag. 	�t���O�𗧂ĂăA�L�������[�^�����[�h���܂��B
	ld (iflag),a		; set interrupt flag. 			���荞�݃t���O��ݒ肵�܂��B
	ex af,af'		; restore accumulator. 			�A�L�������[�^�𕜌����܂��B
	ei			; enable interrupts.			���荞�݂�L���ɂ��܂��B
	reti			; return from interrupt. 			���荞�݂���߂�B
.ends

.orga $0066			; pause button interrupt.	�ꎞ��~�{�^���̊��荞�݁B
.section "pauseButtonHandler" force
	retn			; disable pause button.		�ꎞ��~�{�^���𖳌��ɂ��܂��B
.ends

;=====================
; LIBRARY
;=====================

.include "src\memory.inc"
.include "src\PSGlib.inc"

.include "src\game.asm"
.include "src\tool.asm"

.BANK 1 SLOT 1
.org $0000
.include "src\assets_psg.asm"

.BANK 2 SLOT 2
.org $0000
.include "src\font.asm"

.BANK 3 SLOT 2
.org $0000
.include "src\assets_img.asm"

