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
	di			; disable interrupts.		割り込みを無効にします。
	im 1			; interrupt mode 1.			割り込みモード1。
	ld sp,$dff0		; default stack pointer address.	デフォルトのスタックポインタアドレス。
	jp inigam
.ends

.orga $0038			; frame interrupt address. 			フレーム割り込みアドレス。
.section "vBlankVector" force
	ex af,af'		; save accumulator in its shadow reg.	アキュムレータをシャドウレジスタに保存します。
	in a,$bf		; get vdp status / satisfy interrupt.	vdpステータスを取得/割り込みを満たします。
	ld (status),a		; save vdp status in ram. 			RAMにvdpステータスを保存します。
	ld a,1			; load accumulator with raised flag. 	フラグを立ててアキュムレータをロードします。
	ld (iflag),a		; set interrupt flag. 			割り込みフラグを設定します。
	ex af,af'		; restore accumulator. 			アキュムレータを復元します。
	ei			; enable interrupts.			割り込みを有効にします。
	reti			; return from interrupt. 			割り込みから戻る。
.ends

.orga $0066			; pause button interrupt.	一時停止ボタンの割り込み。
.section "pauseButtonHandler" force
	retn			; disable pause button.		一時停止ボタンを無効にします。
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

