.struct _player
	x db
	y db
	hp db
	img db
.endst

.enum $c000 export	; export labels to symbol file.		���x�����V���{���t�@�C���ɃG�N�X�|�[�g���܂��B

	satbuf dsb 256	; sprite attribute table buffer.	�X�v���C�g�����e�[�u���o�b�t�@�B
			; see the map for object offsets.	�I�u�W�F�N�g�I�t�Z�b�g�̃}�b�v���Q�Ƃ��Ă��������B

	status db	; vdp status (for collision detect.).	vdp�X�e�[�^�X�i�Փˌ��o�p�j�B

	iflag db	; frame interrupt flag.			�t���[�����荞�݃t���O�B

	input db	; input from player 1 controller.		�v���[���[1�R���g���[���[����̓��́B
	is_key db	; �L�[�����������ǂ���

	; �|���Z�Ŏg�p
	na db
	nb db
	nc dsb 2

	text_index dsb 2
	text_loop db

	anime db
	anime2 db

	player instanceOf _player
	enemy instanceOf _player
	ball instanceOf _player

	pick_up db

	flashing db	; �_��
	flashing_x db	; �_�ŁiX���W�ޔ��j
	flashing_y db	; �_�ŁiY���W�ޔ��j

	PaletteBuffer db

.ende


.equ player_tilemap	$00	; �^�C���}�b�v�J�n�ʒu
.equ enemy_tilemap	$10	; �^�C���}�b�v�J�n�ʒu
.equ ball_tilemap	$20	; �^�C���}�b�v�J�n�ʒu

.equ address.player.y   $c000
.equ address.player.x   $c080
.equ address.player.map $c081

.equ address.enemy.y   $c010
.equ address.enemy.x   $c0A0
.equ address.enemy.map $c0A1

.equ address.ball.y   $c020
.equ address.ball.x   $c0C0
.equ address.ball.map $c0C1


; --------------------------------------------------------------
; DATA
; --------------------------------------------------------------
; Initial values for the 11 vdp registers.
.section "regdat" free
regdat
	.db %00000110       ; reg. 0, display and interrupt mode.
                           ; bit 4 = line interrupt (disabled).
                           ; 5 = blank left column (disabled).
                           ; 6 = hori. scroll inhibit (disabled).
                           ; 7 = vert. scroll inhibit (disabled).

       .db %10100001       ; reg. 1, display and interrupt mode.
                           ; bit 0 = zoomed sprites (enabled).
                           ; 1 = 8 x 16 sprites (disabled).
                           ; 5 = frame interrupt (enabled).
                           ; 6 = display (blanked).

       .db $ff             ; reg. 2, name table address.
                           ; $ff = name table at $3800.

       .db $ff             ; reg. 3, n.a.
                           ; always set it to $ff.

       .db $ff             ; reg. 4, n.a.
                           ; always set it to $ff.

       .db $ff             ; reg. 5, sprite attribute table.
                           ; $ff = sprite attrib. table at $3F00.

       .db $ff             ; reg. 6, sprite tile address.
                           ; $ff = sprite tiles in bank 2.

       .db %11110011       ; reg. 7, border color.
                           ; set to color 3 in bank 2.

       .db $00             ; reg. 8, horizontal scroll value = 0.

       .db $00             ; reg. 9, vertical scroll value = 0.

       .db $ff             ; reg. 10, raster line interrupt.
                           ; turn off line int. requests.

.ends