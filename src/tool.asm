; --------------------------------------------------------------
; SUBROUTINES	�T�u���[�`��
; --------------------------------------------------------------

; --------------------------------------------------------------
; MEMORY FILL.
; HL = base address, BC = area size, A = fill byte.
.section "mfill" free
mfill  ld (hl),a           ; load filler byte to base address.
       ld d,h              ; make DE = HL.
       ld e,l
       inc de              ; increment DE to HL + 1.
       dec bc              ; decrement counter.
       ld a,b              ; was BC = 0001 to begin with?
       or c
       ret z               ; yes - then just return.
       ldir                ; else - write filler byte BC times,
                           ; while incrementing DE and HL...
       ret
.ends

; --------------------------------------------------------------
; PREPARE VRAM.							VRAM���������܂��B
; Set up vdp to recieve data at vram address in HL.		HL��vram�A�h���X�Ńf�[�^����M����悤��vdp���Z�b�g�A�b�v���܂��B
.section "vrampr" free
vrampr push af
       ld a,l
       out ($bf),a
       ld a,h
       or $40
       out ($bf),a
       pop af
       ret
.ends

; --------------------------------------------------------------
; WRITE TO VRAM							VRAM�ւ̏�������
; Write BC amount of bytes from data source pointed to by HL.	HL���w���f�[�^�\�[�X����BC�o�C�g���������݂܂��B
; Tip: Use vrampr before calling.				�q���g�F�Ăяo���O��vrampr���g�p���Ă��������B
.section "vramwr" free
vramwr ld a,(hl)
       out ($be),a	; I/O�|�[�g�o�� (�A�L���[�����[�^����)  (n) �� A
       inc hl		; �C���N�������g���W�X�^�[  r �� r + 1
       dec bc		; �f�N�������g���W�X�^�[  r �� r - 1
       ld a,c		; 
       or b		; �_���a(���W�X�^�[)  A �� A �� r
       jp nz,vramwr
       ret
.ends

; --------------------------------------------------------------
; LOAD SPRITE ATTRIBUTE TABLE					�X�v���C�g�����e�[�u���̃��[�h
; Load data into sprite attribute table (SAT) from the buffer.	�o�b�t�@����X�v���C�g�����e�[�u���iSAT�j�Ƀf�[�^�����[�h���܂��B
.section "ldsat" free
ldsat  ld hl,$3f00         ; point to start of SAT in vram.		vram��SAT�̊J�n���|�C���g���܂��B
       call vrampr         ; prepare vram to recieve data.		�f�[�^����M���邽�߂�vram���������܂��B
       ld b,255            ; amount of bytes to output.			�o�͂���o�C�g���B
       ld c,$be            ; destination is vdp data port.		�����vdp�f�[�^�|�[�g�ł��B
       ld hl,satbuf        ; source is start of sat buffer.		�\�[�X�̓o�b�t�@�̊J�n�ł��B
       otir                ; output buffer to vdp.			vdp�ւ̏o�̓o�b�t�@�B
       ret
.ends

; --------------------------------------------------------------
; SET VDP REGISTER.							VDP���W�X�^��ݒ肵�܂��B
; Write to target register.					�^�[�Q�b�g���W�X�^�ɏ������݂܂��B
; A = byte to be loaded into vdp register.	A = vdp���W�X�^�Ƀ��[�h�����o�C�g�B
; B = target register 0-10.					B =�^�[�Q�b�g���W�X�^0~10�B
.section "setreg" free
setreg out ($bf),a         ; output command word 1/2.	�o�̓R�}���h���[�h1/2�B
       ld a,$80
       or b
       out ($bf),a         ; output command word 2/2.	�o�̓R�}���h���[�h2/2�B
       ret
.ends




; --------------------------------------------------------------
; �^�C���}�b�v�̕`��
.section "tilemap_1x1" free
tilemap_1x1
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 1             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,1              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,1             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap_2x2" free
tilemap_2x2
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 2             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,2              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,1             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap4" free
tilemap4
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       ld b,4              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,1             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       djnz -              ; jump back

	ret
.ends

.section "tilemap_3x4" free
tilemap_3x4
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,3              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,1             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap_4x4" free
tilemap_4x4
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,4              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,1             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap32" free
tilemap32
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,8              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,1             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap48" free
tilemap48
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 6             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,6              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,1             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

; --------------------------------------------------------------
; �X�v���C�g�N���A
.section "sprite_clear" free
sprite_clear:
	
	ld hl, $c000
	ld a, 0
       ld c,a              ; save hpos in C				C��hpos��ۑ�����

       .rept 16            ; wladx: Repeat code three times.		wladx�F�R�[�h��3��J��Ԃ��܂��B
       ld a,c              ; load hpos into A				hpos��A�Ƀ��[�h���܂�
       ld b,16             ; loop: Repeat three times.			���[�v�F3��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.		�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       djnz -              ; jump back					�W�����v�o�b�N �����W�����v (B��0)
								;	PC �� PC + e
								;	B �� B - 1
       .endr               ; end of wladx repeat directive.		wladx�̌J��Ԃ����߂̏I���B

	ret

.ends

; --------------------------------------------------------------
; Y���W�̐ݒ�
.section "y_view_1x1" free
y_view_1x1
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 1             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,1              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       .endr               ; end of wladx repeat directive.

	ret
.ends


.section "y_view_2x2" free
y_view_2x2
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 2             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,2              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view_3x4" free
y_view_3x4
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,3              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view_4x4" free
y_view_4x4
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,4              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view32" free
y_view32
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,8              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view48" free
y_view48
       ld c,a              ; save hpos in C						C��hpos��ۑ�����

       .rept 6             ; wladx: Repeat code four times.		wladx�F�R�[�h��4��J��Ԃ��܂��B
       ld b,6              ; loop: Repeat four times.			���[�v�F4��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.	�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8�i�s�N�Z���P�ʂ̃^�C���̕��j��ǉ����܂��B
       .endr               ; end of wladx repeat directive.

	ret
.ends


; --------------------------------------------------------------
; X���W�̐ݒ�
.section "x_view_1x1" free
x_view_1x1
       ld c,a              ; save hpos in C				C��hpos��ۑ�����

       .rept 1             ; wladx: Repeat code three times.		wladx�F�R�[�h��3��J��Ԃ��܂��B
       ld a,c              ; load hpos into A				hpos��A�Ƀ��[�h���܂�
       ld b,1              ; loop: Repeat three times.			���[�v�F3��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.		�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,8             ; add nothing.				�����ǉ����܂���B
       djnz -              ; jump back					�W�����v�o�b�N �����W�����v (B��0)
								;	PC �� PC + e
								;	B �� B - 1
       .endr               ; end of wladx repeat directive.		wladx�̌J��Ԃ����߂̏I���B

	ret
.ends

.section "x_view_2x2" free
x_view_2x2
       ld c,a              ; save hpos in C				C��hpos��ۑ�����

       .rept 2             ; wladx: Repeat code three times.		wladx�F�R�[�h��3��J��Ԃ��܂��B
       ld a,c              ; load hpos into A				hpos��A�Ƀ��[�h���܂�
       ld b,2              ; loop: Repeat three times.			���[�v�F3��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.		�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,8             ; add nothing.				�����ǉ����܂���B
       djnz -              ; jump back					�W�����v�o�b�N �����W�����v (B��0)
								;	PC �� PC + e
								;	B �� B - 1
       .endr               ; end of wladx repeat directive.		wladx�̌J��Ԃ����߂̏I���B

	ret
.ends

.section "x_view_3x4" free
x_view_3x4
       ld c,a              ; save hpos in C				C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code three times.		wladx�F�R�[�h��3��J��Ԃ��܂��B
       ld a,c              ; load hpos into A				hpos��A�Ƀ��[�h���܂�
       ld b,3              ; loop: Repeat three times.			���[�v�F3��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.		�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,8             ; add nothing.				�����ǉ����܂���B
       djnz -              ; jump back					�W�����v�o�b�N �����W�����v (B��0)
								;	PC �� PC + e
								;	B �� B - 1
       .endr               ; end of wladx repeat directive.		wladx�̌J��Ԃ����߂̏I���B

	ret
.ends

.section "x_view_4x4" free
x_view_4x4
       ld c,a              ; save hpos in C				C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code three times.		wladx�F�R�[�h��3��J��Ԃ��܂��B
       ld a,c              ; load hpos into A				hpos��A�Ƀ��[�h���܂�
       ld b,4              ; loop: Repeat three times.			���[�v�F3��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.		�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,8             ; add nothing.				�����ǉ����܂���B
       djnz -              ; jump back					�W�����v�o�b�N �����W�����v (B��0)
								;	PC �� PC + e
								;	B �� B - 1
       .endr               ; end of wladx repeat directive.		wladx�̌J��Ԃ����߂̏I���B

	ret
.ends

.section "x_view32" free
x_view32
       ld c,a              ; save hpos in C				C��hpos��ۑ�����

       .rept 4             ; wladx: Repeat code three times.		wladx�F�R�[�h��3��J��Ԃ��܂��B
       ld a,c              ; load hpos into A				hpos��A�Ƀ��[�h���܂�
       ld b,8              ; loop: Repeat three times.			���[�v�F3��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.		�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,8             ; add nothing.				�����ǉ����܂���B
       djnz -              ; jump back					�W�����v�o�b�N �����W�����v (B��0)
								;	PC �� PC + e
								;	B �� B - 1
       .endr               ; end of wladx repeat directive.		wladx�̌J��Ԃ����߂̏I���B

	ret
.ends

.section "x_view48" free
x_view48
       ld c,a              ; save hpos in C				C��hpos��ۑ�����

       .rept 6             ; wladx: Repeat code three times.		wladx�F�R�[�h��3��J��Ԃ��܂��B
       ld a,c              ; load hpos into A				hpos��A�Ƀ��[�h���܂�
       ld b,6              ; loop: Repeat three times.			���[�v�F3��J��Ԃ��܂��B
-      ld (hl),a           ; write value to buffer at address.		�A�h���X�̃o�b�t�@�ɒl���������݂܂��B
       inc hl              ; skip over the char code byte.		�����R�[�h�o�C�g���X�L�b�v���܂��B
       inc hl              ; point to next hpos byte in buffer.	�o�b�t�@���̎���hpos�o�C�g���w���܂��B
       add a,8             ; add nothing.				�����ǉ����܂���B
       djnz -              ; jump back					�W�����v�o�b�N �����W�����v (B��0)
								;	PC �� PC + e
								;	B �� B - 1
       .endr               ; end of wladx repeat directive.		wladx�̌J��Ԃ����߂̏I���B

	ret
.ends


; --------------------------------------------------------------
; GET KEYS.							�L�[���擾���܂��B
; Read player 1 keys (port $dc) into ram mirror (input).	�v���[���[1�L�[�i�|�[�g$ dc�j��RAM�~���[�i���́j�ɓǂݍ��݂܂��B
; 0:��{�^��
; 1:�Ȃ�
; 2:�Ȃ�
; 3:�E�{�^��
; 4:�P�{�^��
; 5:�Q�{�^��
; 6:�Ȃ�
; 7:�Ȃ�
.section "getkey" free
getkey:
	in a,$dc            ; read player 1 input port $dc.	�v���[���[1�̓��̓|�[�g$ dc��ǂݎ��܂��B
	ld (input),a        ; let variable mirror port status.	let variable mirror port status.
	ret
.ends


; getInput
;
; gets input from buttons
;
; start button from port $00
; D-pad an button 1, 2 from port $dc
; stored bitwise in memory adress: input

; bit masks for buttons in input byte
.equ upMask          %00000001
.equ downMask        %00000010
.equ leftMask        %00000100
.equ rightMask       %00001000
.equ allDpadMask     %00001111 ; all direction buttons are pressed
.equ button1Mask     %00010000
.equ button2Mask     %00100000
.equ startButtonMask %10000000

; 0:��L�[
; 1:
; 2:���L�[
; 3:�E�L�[
; 4:�P�L�[
; 5:�Q�L�[
; 6:
; 7:�X�^�[�g�L�[
.section "getInput" free
getInput:
    ; start button
    in a,$00
    and startButtonMask
    ld b, a

    ; other buttons (D-pad, button 1 and 2)
    in a,$dc
    and allDpadMask | button1Mask | button2Mask
    or b ; add start button bit, if present

    ld (input), a
    ret
.ends


;=================================================================================
; Quick palette fade
;=================================================================================

.section "FadeInScreen" free
FadeInScreen:

    halt                   ; wait for Vblank

    ld (PaletteBuffer),hl

    xor a
    out ($bf),a            ; palette index (0)
    ld a,$c0
    out ($bf),a            ; palette write identifier

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,(PaletteBuffer)  ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    srl a                  ; modify color values: 2 becomes 1
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,(PaletteBuffer)  ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,(PaletteBuffer)  ; source
 -: ld a,(hl)              ; load raw palette data
    out ($be),a            ; write unfodified data to CRAM, palette load complete
    inc hl
    djnz -

    ret
.ends

;---------------------------------------------------------------------------------
.section "FadeOutScreen" free
FadeOutScreen:

    halt                   ; wait for Vblank

    ld (PaletteBuffer),hl

    xor a
    out ($bf),a            ; palette index (0)
    ld a,$c0
    out ($bf),a            ; palette write identifier

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,(PaletteBuffer)  ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,(PaletteBuffer)  ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    srl a                  ; modify color values: 2 becomes 1
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b, 32               ; number of palette entries: 32 (full palette)
    xor a                  ; we want to blacken the palette, so a is set to 0
 -: out ($be), a           ; write zeros to CRAM, palette fade complete
    djnz -

    ret

.ends
















;=================================================================================
; �����\��
;=================================================================================

; �������^�C���}�b�v�ɃZ�b�g
.section "font_set" free
font_set:

	push hl
	ld (text_loop),a

-
	pop hl
	ld a, (hl)

	inc hl
	inc hl
	push hl

	ld (na), a
	ld a, $20
	ld (nb), a
	call multi
	ld bc, (nc)

	ld hl,font_tiles
	add hl,bc

	ld bc,32		; each tiles is 32 bytes.		�e�^�C����32�o�C�g�ł��B
	call vramwr

	ld a,(text_loop)
	sub 1
	ld (text_loop),a
	cp 0
	jr nz, -

	pop hl	; �I���������o���Ă���

	ret

.ends




;=================================================================================
; �|���Z
; http://ldlabo.hishaku.com/NO24/hontai.htm
;=================================================================================
.section "multi" free
multi:

	ld hl, 0
	ld b, l
	ld a, (na)
	ld c, a
	ld a, (nb)
multi_loop:
	sla	c
	rl	b
	srl	a
	jr	nc, multi_loop
	ld	d, b
	ld	e, c
	add	hl, de
	cp	0
	jr	nz, multi_loop
	srl	h
	rr	l
	ld	(nc), hl
	ret

.ends


