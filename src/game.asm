;========================================================================================
; 初期化、ロゴ（タイトル画面）
;========================================================================================

.section "game" free
inigam:

	; BANK切り替え
	ld a, :font_palette
	ld (BANK_SWITCH), a

	; PSGのストップ
	call PSGStop        ; turn off the music.		音楽をオフにします。

	ld hl,$c000         ; point to beginning of ram.	RAMの始まりを指します。
	ld bc,$1000         ; 4 kb to fill.			記入する4 kb。
	ld a,0              ; with value 0.			値0で。
	call mfill          ; do it!				実行

	ld hl,$0000         ; prepare vram for data at $0000.	データ用のvramを準備します。
	call vrampr
	ld b,4              ; write 4 x 4 kb = 16 kb.
-	push bc             ; save the counter.			カウンターを保存します。
	ld hl,$c000         ; source = freshly initialized ram.	新しく初期化されたRAM
	ld bc,$1000         ; 4 kb of zeroes.			4 kbのゼロ。
	call vramwr         ; purge vram.			VRAMをパージします。
	pop bc              ; retrieve counter.			カウンターを取得します。
	djnz -

	ld hl,regdat        ; point to register init data.	初期化データを登録することを指します。
	ld b,11             ; 11 bytes of register data.		11バイトのレジスタデータ。
	ld c,$80            ; VDP register command byte.		VDPレジスタコマンドバイト。

-	ld a,(hl)           ; load one byte of data into A.	1バイトのデータをAにロードします。
	out ($bf),a         ; output data to VDP command port.	VDPコマンドポートにデータを出力します。
	ld a,c              ; load the command byte.		コマンドバイトをロードします。
	out ($bf),a         ; output it to the VDP command port.	VDPコマンドポートに出力します。
	inc hl              ; inc. pointer to next byte of data.	incデータの次のバイトへのポインター。
	inc c               ; inc. command byte to next register.incコマンドバイトから次のレジスタへ。
	djnz -              ; jump back to '-' if b > 0.		b> 0の場合、「-」に戻ります。

	call PSGInit        ; credit goes to sverx!		クレジットはsverxに行きます

	xor a
	ld b,9              ; reset scroll value.		スクロール値をリセットします。
	call setreg         ; set register 1.			レジスタ1を設定します。

	ld a,%11100000      ; enable screen			画面を有効にする
	ld b,1              ; register 1.			レジスタ1。
	call setreg         ; set register.			レジスタを設定します

	ei                  ; turn interrupts on.		割り込みをオンにします。

	xor a	; 念のため初期化





	; BANK切り替え
	ld a, :logo_bg_tiles
	ld (BANK_SWITCH), a

	; 背景の変更
	ld hl,$0000
	call vrampr
	ld hl,logo_bg_tiles
	ld bc,31*32	; each tiles is 32 bytes.
	call vramwr

	ld hl,$3800
	call vrampr
	ld hl,logo_bg_tilemap
	ld bc,32*28*2	; each is 2 bytes.
	call vramwr




	; TODO パレット２のフェードアウトに対応していないので、
	; パレット２
	ld hl,$c020
	call vrampr		; prepare vram.			VRAMを準備します。
	ld hl,kuro1_palette	; background palette.		背景パレット。
	ld bc,32		; 32固定
	call vramwr		; set background palette.	背景パレットを設定します。

	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,kuro1_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ld a, kuro_tilemap
	ld hl,address_kuro_map
	call tilemap48

	; 座標
	ld a, 62
	ld hl,address_kuro_x
	call x_view48

	ld a, 72
	ld hl,address_kuro_y
	call y_view48

	call ldsat          ; スプライトの反映

	; フェードイン
	ld hl, logo_bg_palette
	CALL FadeInScreen

	ld a, 0
	ld (anime), a
	ld (anime2), a


logo_loop:
	halt			; start main loop with vblank.	メインループをvblankで開始します。
				; HALT は 割り込み/リセットがくるまで，NOP を実行します
				; NOPは何もしない命令に見えますが，実際はメモリーから命令を読み込みプログラムカウンターをひとつ進めています．

	; スタートボタンを押したかどうか
	in     a,($00)
	and    %10000000
	jp z, logo_end


	; アニメーション
	ld a, (anime)
	add a, 1
	ld (anime), a

	ld a, (anime2)
	cp 3
	jp z, sleep_anime
	
	ld a, (anime)
	cp 200
	call z, logo_anime_2
	cp 205
	call z, logo_anime_3
	cp 210
	call z, logo_anime_2
	cp 215
	call z, logo_anime_1
	cp 255
	call z, add_anime2
	
	jp add_anime_end

add_anime2:
	ld a, (anime2)
	add a, 1
	ld (anime2), a

	jp add_anime_end

sleep_anime:

	ld a, (anime)
	cp 120
	call z, logo_anime_4
	cp 150
	call z, logo_anime_5
	cp 180
	call z, logo_anime_4
	cp 210
	call z, logo_anime_5
	cp 240
	call z, logo_anime_1
	cp 255
	call z, reset_anime2

	jp add_anime_end

reset_anime2:
	ld a, 0
	ld (anime2), a
	jp add_anime_end

add_anime_end:

	call ldsat          ; スプライトの反映

	jp logo_loop


logo_anime_1:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。

	ld hl,kuro1_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ret

logo_anime_2:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。

	ld hl,kuro2_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ret

logo_anime_3:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。

	ld hl,kuro3_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ret

logo_anime_4:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。

	ld hl,kuro4_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ret

logo_anime_5:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。

	ld hl,kuro5_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ret








logo_end:
	
	; フェードアウト
	ld hl, logo_bg_palette
	CALL FadeOutScreen
	
	; スプライトクリア
	call sprite_clear
	call ldsat
	
	jp title_init






; ===============================================================
; タイトル
; ===============================================================




title_init:

	; 曲の変更
	call PSGStop
	ld a, :opening_bgm
	ld hl,opening_bgm
	call PSGPlay

	; BANK切り替え
	ld a, :bg_tiles
	ld (BANK_SWITCH), a

	; 背景の変更
	ld hl,$0000
	call vrampr
	ld hl,bg_tiles
	ld bc,6*32	; each tiles is 32 bytes.
	call vramwr

	ld hl,$3800
	call vrampr
	ld hl,bg_tilemap
	ld bc,32*28*2	; each is 2 bytes.
	call vramwr

	; BANK切り替え
	ld a, :font_palette
	ld (BANK_SWITCH), a

	; PUSH START
	ld hl,$0200
	call vrampr
	ld hl, text1
	ld a,10
	call font_set

	ld hl,$3AD6	; 座標
	call vrampr
	ld hl,font_tilemap2
	ld bc,10*2		; each is 2 bytes.
	call vramwr


	; ボールなげあいゲーム＿濁点
	ld hl,$0400
	call vrampr
	ld hl, text02
	ld a,12
	call font_set

	ld hl,$3994	; 座標
	call vrampr
	ld hl,font_tilemap3
	ld bc,12*2		; each is 2 bytes.
	call vramwr

	; ボールなげあいゲーム
	ld hl,$0600
	call vrampr
	ld hl, text2
	ld a,12
	call font_set

	ld hl,$39D4	; 座標
	call vrampr
	ld hl,font_tilemap4
	ld bc,12*2		; each is 2 bytes.
	call vramwr

	; 空白
	ld hl,$0800
	call vrampr
	ld hl, text3
	ld a,12
	call font_set

	ld hl,$3A14	; 座標
	call vrampr
	ld hl,font_tilemap5
	ld bc,12*2		; each is 2 bytes.
	call vramwr


	; BANK切り替え
	ld a, :bg_tiles
	ld (BANK_SWITCH), a


	; スプライトの登録

	; プレイヤーの描画
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,player1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	; タイルマップ
	ld a, player_tilemap
	ld hl, address.player.map
	call tilemap_3x4
	
	; 座標
	ld a, 84
	ld (player.x), a
	ld a, 100
	ld (player.y), a

	ld a, (player.x)
	ld hl,address.player.x
	call x_view_3x4

	ld a, (player.y)
	ld hl,address.player.y
	call y_view_3x4



	; エネミーの描画
	ld hl,$2200
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,enemy1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	; タイルマップ
	ld a, enemy_tilemap
	ld hl,address.enemy.map
	call tilemap_3x4
	
	; 座標
	ld a, 140
	ld (enemy.x), a
	ld a, 100
	ld (enemy.y), a

	ld a, (enemy.x)
	ld hl,address.enemy.x
	call x_view_3x4

	ld a, (enemy.y)
	ld hl,address.enemy.y
	call y_view_3x4

	call ldsat          ; スプライトの反映

	; フェードイン
	ld hl, bg_palette
	CALL FadeInScreen

	; TODO パレット２のフェードアウトに対応していないので、
	; パレット２
	ld hl,$c020
	call vrampr		; prepare vram.			VRAMを準備します。
	ld hl,player1_palette	; background palette.		背景パレット。
	ld bc,32		; 32固定
	call vramwr		; set background palette.	背景パレットを設定します。




title_loop:
	halt			; start main loop with vblank.	メインループをvblankで開始します。
				; HALT は 割り込み/リセットがくるまで，NOP を実行します
				; NOPは何もしない命令に見えますが，実際はメモリーから命令を読み込みプログラムカウンターをひとつ進めています．

	; BGMの再生
	call PSGFrame


	; アニメーション
	ld a, (anime)
	add a, 1
	ld (anime), a
	cp 30
	call z, animation2
	cp 60
	call z, animation1


	; スタートボタンを押したかどうか
	in     a,($00)
	and    %10000000
	jp z, title_end

	jp title_loop

title_end:

	jp game_init


game_init:

	; アニメーション初期化
	ld a, 0
	ld (anime), a

	; 背景の変更
	ld hl,$0000
	call vrampr
	ld hl,bg_tiles
	ld bc,6*32	; each tiles is 32 bytes.
	call vramwr

	ld hl,$3800
	call vrampr
	ld hl,bg_tilemap
	ld bc,32*28*2	; each is 2 bytes.
	call vramwr


	; =============================
	; ボール
	; =============================

	; ボールをタイルにセット
	ld hl,$2400
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,ball_tiles
	ld bc,1*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	; タイルマップ
	ld a, ball_tilemap
	ld hl, address.ball.map
	call tilemap_1x1
	
	; 座標
	ld a, 160
	ld (ball.x), a
	ld a, 80
	ld (ball.y), a


	; フェードイン
	ld hl, bg_palette
	CALL FadeInScreen

	; TODO パレット２のフェードアウトに対応していないので、
	; パレット２
	ld hl,$c020
	call vrampr		; prepare vram.			VRAMを準備します。
	ld hl,player1_palette	; background palette.		背景パレット。
	ld bc,32		; 32固定
	call vramwr		; set background palette.	背景パレットを設定します。


	; 拾ったかどうかのフラグ
	ld a, 0
	ld (pick_up), a

game_loop:
	halt			; start main loop with vblank.	メインループをvblankで開始します。
				; HALT は 割り込み/リセットがくるまで，NOP を実行します
				; NOPは何もしない命令に見えますが，実際はメモリーから命令を読み込みプログラムカウンターをひとつ進めています．

	; BGMの再生
	call PSGFrame



	; アニメーション
	ld a, (anime)
	add a, 1
	ld (anime), a
	cp 10
	call z, animation2
	cp 20
	call z, animation1




	; キー入力
	call getInput       ; read controller port.

	; 上ボタン
	ld a,(input)        ; read input from ram mirror.
	bit 0,a             ; is right key pressed?
	call z,player_up

	; 下ボタン
	ld a,(input)        ; read input from ram mirror.
	bit 1,a             ; is right key pressed?
	call z,player_down

	; 左ボタン
	ld a,(input)        ; read input from ram mirror.
	bit 2,a             ; is right key pressed?
	call z,player_left

	; 右ボタン
	ld a,(input)        ; read input from ram mirror.
	bit 3,a             ; is right key pressed?
	call z,player_right



	; エネミーの思考












	; ボールを拾ったかどうか
	ld a, (ball.x)
	ld b, a
	ld a, (player.x)
	sub 16
	cp b
	jp c, ball_pick_up1
	jp nc, ball_pick_up_end
	
ball_pick_up1:

	ld a, (ball.x)
	ld b, a
	ld a, (player.x)
	add a, 24
	cp b
	jp nc, ball_pick_up2
	jp c, ball_pick_up_end

ball_pick_up2:

	ld a, (ball.y)
	ld b, a
	ld a, (player.y)
	sub 16
	cp b
	jp c, ball_pick_up3
	jp nc, ball_pick_up_end

ball_pick_up3:

	ld a, (ball.y)
	ld b, a
	ld a, (player.y)
	add a, 24
	cp b
	jp nc, ball_pick_up4
	jp c, ball_pick_up_end

ball_pick_up4:

	ld a, (player.x)
	add a, 16
	ld (ball.x), a
	ld a, (player.y)
	add a, 8
	ld (ball.y), a
	
ball_pick_up_end:




	; プレイヤーの描画
	ld a, (player.x)
	ld hl,address.player.x
	call x_view_3x4

	ld a, (player.y)
	ld hl,address.player.y
	call y_view_3x4


	; エネミーの描画
	ld a, (enemy.x)
	ld hl,address.enemy.x
	call x_view_3x4

	ld a, (enemy.y)
	ld hl,address.enemy.y
	call y_view_3x4

	; ボールの描画
	ld a, (ball.x)
	ld hl,address.ball.x
	call x_view_1x1

	ld a, (ball.y)
	ld hl,address.ball.y
	call y_view_1x1


	call ldsat          ; スプライトの反映


	jp game_loop



animation1:
	; スプライトの変更
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,player1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ld hl,$2200
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,enemy1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	xor a
	ld (anime), a

	ret

animation2:
	; スプライトの変更
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,player2_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ld hl,$2200
	call  vrampr		; prepare vram at the above address.	上記のアドレスでvramを準備します。
	ld hl,enemy2_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60タイル。各タイルは32バイトです。
	call vramwr		; write characters to vram.		vramに文字を書き込みます。

	ret





player_up:
	ld a, (player.y)
	sub 1
	ld (player.y), a
	ret

player_down:
	ld a, (player.y)
	add a, 1
	ld (player.y), a
	ret

player_left:
	ld a, (player.x)
	sub 1
	ld (player.x), a
	ret

player_right:
	ld a, (player.x)
	add a, 1
	ld (player.x), a
	ret


game_end:



game_wim:



game_lose:






.ends
