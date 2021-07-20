.struct _player
	x db
	y db
	hp db
	img db
.endst

.enum $c000 export	; export labels to symbol file.		ラベルをシンボルファイルにエクスポートします。

	satbuf dsb 256	; sprite attribute table buffer.	スプライト属性テーブルバッファ。
			; see the map for object offsets.	オブジェクトオフセットのマップを参照してください。

	status db	; vdp status (for collision detect.).	vdpステータス（衝突検出用）。

	iflag db	; frame interrupt flag.			フレーム割り込みフラグ。

	input db	; input from player 1 controller.		プレーヤー1コントローラーからの入力。
	is_key db	; キーを押したかどうか

	; 掛け算で使用
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

	flashing db	; 点滅
	flashing_x db	; 点滅（X座標退避）
	flashing_y db	; 点滅（Y座標退避）

	PaletteBuffer db

.ende


.equ player_tilemap	$00	; タイルマップ開始位置
.equ enemy_tilemap	$10	; タイルマップ開始位置
.equ ball_tilemap	$20	; タイルマップ開始位置

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
