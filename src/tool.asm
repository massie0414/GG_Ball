; --------------------------------------------------------------
; SUBROUTINES	サブルーチン
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
; PREPARE VRAM.							VRAMを準備します。
; Set up vdp to recieve data at vram address in HL.		HLのvramアドレスでデータを受信するようにvdpをセットアップします。
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
; WRITE TO VRAM							VRAMへの書き込み
; Write BC amount of bytes from data source pointed to by HL.	HLが指すデータソースからBCバイトを書き込みます。
; Tip: Use vrampr before calling.				ヒント：呼び出す前にvramprを使用してください。
.section "vramwr" free
vramwr ld a,(hl)
       out ($be),a	; I/Oポート出力 (アキュームレータから)  (n) ← A
       inc hl		; インクリメントレジスター  r ← r + 1
       dec bc		; デクリメントレジスター  r ← r - 1
       ld a,c		; 
       or b		; 論理和(レジスター)  A ← A ∨ r
       jp nz,vramwr
       ret
.ends

; --------------------------------------------------------------
; LOAD SPRITE ATTRIBUTE TABLE					スプライト属性テーブルのロード
; Load data into sprite attribute table (SAT) from the buffer.	バッファからスプライト属性テーブル（SAT）にデータをロードします。
.section "ldsat" free
ldsat  ld hl,$3f00         ; point to start of SAT in vram.		vramでSATの開始をポイントします。
       call vrampr         ; prepare vram to recieve data.		データを受信するためにvramを準備します。
       ld b,255            ; amount of bytes to output.			出力するバイト数。
       ld c,$be            ; destination is vdp data port.		宛先はvdpデータポートです。
       ld hl,satbuf        ; source is start of sat buffer.		ソースはバッファの開始です。
       otir                ; output buffer to vdp.			vdpへの出力バッファ。
       ret
.ends

; --------------------------------------------------------------
; SET VDP REGISTER.							VDPレジスタを設定します。
; Write to target register.					ターゲットレジスタに書き込みます。
; A = byte to be loaded into vdp register.	A = vdpレジスタにロードされるバイト。
; B = target register 0-10.					B =ターゲットレジスタ0~10。
.section "setreg" free
setreg out ($bf),a         ; output command word 1/2.	出力コマンドワード1/2。
       ld a,$80
       or b
       out ($bf),a         ; output command word 2/2.	出力コマンドワード2/2。
       ret
.ends




; --------------------------------------------------------------
; タイルマップの描画
.section "tilemap_1x1" free
tilemap_1x1
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 1             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,1              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,1             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap_2x2" free
tilemap_2x2
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 2             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,2              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,1             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap4" free
tilemap4
       ld c,a              ; save hpos in C						Cでhposを保存する

       ld b,4              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,1             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       djnz -              ; jump back

	ret
.ends

.section "tilemap_3x4" free
tilemap_3x4
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 4             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,3              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,1             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap_4x4" free
tilemap_4x4
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 4             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,4              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,1             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap32" free
tilemap32
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 4             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,8              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,1             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "tilemap48" free
tilemap48
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 6             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,6              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,1             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       djnz -              ; jump back
       .endr               ; end of wladx repeat directive.

	ret
.ends

; --------------------------------------------------------------
; スプライトクリア
.section "sprite_clear" free
sprite_clear:
	
	ld hl, $c000
	ld a, 0
       ld c,a              ; save hpos in C				Cでhposを保存する

       .rept 16            ; wladx: Repeat code three times.		wladx：コードを3回繰り返します。
       ld a,c              ; load hpos into A				hposをAにロードします
       ld b,16             ; loop: Repeat three times.			ループ：3回繰り返します。
-      ld (hl),a           ; write value to buffer at address.		アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       djnz -              ; jump back					ジャンプバック 条件ジャンプ (B≠0)
								;	PC ← PC + e
								;	B ← B - 1
       .endr               ; end of wladx repeat directive.		wladxの繰り返し命令の終わり。

	ret

.ends

; --------------------------------------------------------------
; Y座標の設定
.section "y_view_1x1" free
y_view_1x1
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 1             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,1              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       .endr               ; end of wladx repeat directive.

	ret
.ends


.section "y_view_2x2" free
y_view_2x2
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 2             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,2              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view_3x4" free
y_view_3x4
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 4             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,3              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view_4x4" free
y_view_4x4
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 4             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,4              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view32" free
y_view32
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 4             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,8              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       .endr               ; end of wladx repeat directive.

	ret
.ends

.section "y_view48" free
y_view48
       ld c,a              ; save hpos in C						Cでhposを保存する

       .rept 6             ; wladx: Repeat code four times.		wladx：コードを4回繰り返します。
       ld b,6              ; loop: Repeat four times.			ループ：4回繰り返します。
-      ld (hl),a           ; write value to buffer at address.	アドレスのバッファに値を書き込みます。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       djnz -              ; jump back
       add a,8             ; add 8 (a tile's width in pixels).	8（ピクセル単位のタイルの幅）を追加します。
       .endr               ; end of wladx repeat directive.

	ret
.ends


; --------------------------------------------------------------
; X座標の設定
.section "x_view_1x1" free
x_view_1x1
       ld c,a              ; save hpos in C				Cでhposを保存する

       .rept 1             ; wladx: Repeat code three times.		wladx：コードを3回繰り返します。
       ld a,c              ; load hpos into A				hposをAにロードします
       ld b,1              ; loop: Repeat three times.			ループ：3回繰り返します。
-      ld (hl),a           ; write value to buffer at address.		アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,8             ; add nothing.				何も追加しません。
       djnz -              ; jump back					ジャンプバック 条件ジャンプ (B≠0)
								;	PC ← PC + e
								;	B ← B - 1
       .endr               ; end of wladx repeat directive.		wladxの繰り返し命令の終わり。

	ret
.ends

.section "x_view_2x2" free
x_view_2x2
       ld c,a              ; save hpos in C				Cでhposを保存する

       .rept 2             ; wladx: Repeat code three times.		wladx：コードを3回繰り返します。
       ld a,c              ; load hpos into A				hposをAにロードします
       ld b,2              ; loop: Repeat three times.			ループ：3回繰り返します。
-      ld (hl),a           ; write value to buffer at address.		アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,8             ; add nothing.				何も追加しません。
       djnz -              ; jump back					ジャンプバック 条件ジャンプ (B≠0)
								;	PC ← PC + e
								;	B ← B - 1
       .endr               ; end of wladx repeat directive.		wladxの繰り返し命令の終わり。

	ret
.ends

.section "x_view_3x4" free
x_view_3x4
       ld c,a              ; save hpos in C				Cでhposを保存する

       .rept 4             ; wladx: Repeat code three times.		wladx：コードを3回繰り返します。
       ld a,c              ; load hpos into A				hposをAにロードします
       ld b,3              ; loop: Repeat three times.			ループ：3回繰り返します。
-      ld (hl),a           ; write value to buffer at address.		アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,8             ; add nothing.				何も追加しません。
       djnz -              ; jump back					ジャンプバック 条件ジャンプ (B≠0)
								;	PC ← PC + e
								;	B ← B - 1
       .endr               ; end of wladx repeat directive.		wladxの繰り返し命令の終わり。

	ret
.ends

.section "x_view_4x4" free
x_view_4x4
       ld c,a              ; save hpos in C				Cでhposを保存する

       .rept 4             ; wladx: Repeat code three times.		wladx：コードを3回繰り返します。
       ld a,c              ; load hpos into A				hposをAにロードします
       ld b,4              ; loop: Repeat three times.			ループ：3回繰り返します。
-      ld (hl),a           ; write value to buffer at address.		アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,8             ; add nothing.				何も追加しません。
       djnz -              ; jump back					ジャンプバック 条件ジャンプ (B≠0)
								;	PC ← PC + e
								;	B ← B - 1
       .endr               ; end of wladx repeat directive.		wladxの繰り返し命令の終わり。

	ret
.ends

.section "x_view32" free
x_view32
       ld c,a              ; save hpos in C				Cでhposを保存する

       .rept 4             ; wladx: Repeat code three times.		wladx：コードを3回繰り返します。
       ld a,c              ; load hpos into A				hposをAにロードします
       ld b,8              ; loop: Repeat three times.			ループ：3回繰り返します。
-      ld (hl),a           ; write value to buffer at address.		アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,8             ; add nothing.				何も追加しません。
       djnz -              ; jump back					ジャンプバック 条件ジャンプ (B≠0)
								;	PC ← PC + e
								;	B ← B - 1
       .endr               ; end of wladx repeat directive.		wladxの繰り返し命令の終わり。

	ret
.ends

.section "x_view48" free
x_view48
       ld c,a              ; save hpos in C				Cでhposを保存する

       .rept 6             ; wladx: Repeat code three times.		wladx：コードを3回繰り返します。
       ld a,c              ; load hpos into A				hposをAにロードします
       ld b,6              ; loop: Repeat three times.			ループ：3回繰り返します。
-      ld (hl),a           ; write value to buffer at address.		アドレスのバッファに値を書き込みます。
       inc hl              ; skip over the char code byte.		文字コードバイトをスキップします。
       inc hl              ; point to next hpos byte in buffer.	バッファ内の次のhposバイトを指します。
       add a,8             ; add nothing.				何も追加しません。
       djnz -              ; jump back					ジャンプバック 条件ジャンプ (B≠0)
								;	PC ← PC + e
								;	B ← B - 1
       .endr               ; end of wladx repeat directive.		wladxの繰り返し命令の終わり。

	ret
.ends


; --------------------------------------------------------------
; GET KEYS.							キーを取得します。
; Read player 1 keys (port $dc) into ram mirror (input).	プレーヤー1キー（ポート$ dc）をRAMミラー（入力）に読み込みます。
; 0:上ボタン
; 1:なし
; 2:なし
; 3:右ボタン
; 4:１ボタン
; 5:２ボタン
; 6:なし
; 7:なし
.section "getkey" free
getkey:
	in a,$dc            ; read player 1 input port $dc.	プレーヤー1の入力ポート$ dcを読み取ります。
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

; 0:上キー
; 1:
; 2:左キー
; 3:右キー
; 4:１キー
; 5:２キー
; 6:
; 7:スタートキー
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
; 文字表示
;=================================================================================

; 文字をタイルマップにセット
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

	ld bc,32		; each tiles is 32 bytes.		各タイルは32バイトです。
	call vramwr

	ld a,(text_loop)
	sub 1
	ld (text_loop),a
	cp 0
	jr nz, -

	pop hl	; 終わったら取り出しておく

	ret

.ends




;=================================================================================
; 掛け算
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


