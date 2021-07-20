;========================================================================================
; �������A���S�i�^�C�g����ʁj
;========================================================================================

.section "game" free
inigam:

	; BANK�؂�ւ�
	ld a, :font_palette
	ld (BANK_SWITCH), a

	; PSG�̃X�g�b�v
	call PSGStop        ; turn off the music.		���y���I�t�ɂ��܂��B

	ld hl,$c000         ; point to beginning of ram.	RAM�̎n�܂���w���܂��B
	ld bc,$1000         ; 4 kb to fill.			�L������4 kb�B
	ld a,0              ; with value 0.			�l0�ŁB
	call mfill          ; do it!				���s

	ld hl,$0000         ; prepare vram for data at $0000.	�f�[�^�p��vram���������܂��B
	call vrampr
	ld b,4              ; write 4 x 4 kb = 16 kb.
-	push bc             ; save the counter.			�J�E���^�[��ۑ����܂��B
	ld hl,$c000         ; source = freshly initialized ram.	�V�������������ꂽRAM
	ld bc,$1000         ; 4 kb of zeroes.			4 kb�̃[���B
	call vramwr         ; purge vram.			VRAM���p�[�W���܂��B
	pop bc              ; retrieve counter.			�J�E���^�[���擾���܂��B
	djnz -

	ld hl,regdat        ; point to register init data.	�������f�[�^��o�^���邱�Ƃ��w���܂��B
	ld b,11             ; 11 bytes of register data.		11�o�C�g�̃��W�X�^�f�[�^�B
	ld c,$80            ; VDP register command byte.		VDP���W�X�^�R�}���h�o�C�g�B

-	ld a,(hl)           ; load one byte of data into A.	1�o�C�g�̃f�[�^��A�Ƀ��[�h���܂��B
	out ($bf),a         ; output data to VDP command port.	VDP�R�}���h�|�[�g�Ƀf�[�^���o�͂��܂��B
	ld a,c              ; load the command byte.		�R�}���h�o�C�g�����[�h���܂��B
	out ($bf),a         ; output it to the VDP command port.	VDP�R�}���h�|�[�g�ɏo�͂��܂��B
	inc hl              ; inc. pointer to next byte of data.	inc�f�[�^�̎��̃o�C�g�ւ̃|�C���^�[�B
	inc c               ; inc. command byte to next register.inc�R�}���h�o�C�g���玟�̃��W�X�^�ցB
	djnz -              ; jump back to '-' if b > 0.		b> 0�̏ꍇ�A�u-�v�ɖ߂�܂��B

	call PSGInit        ; credit goes to sverx!		�N���W�b�g��sverx�ɍs���܂�

	xor a
	ld b,9              ; reset scroll value.		�X�N���[���l�����Z�b�g���܂��B
	call setreg         ; set register 1.			���W�X�^1��ݒ肵�܂��B

	ld a,%11100000      ; enable screen			��ʂ�L���ɂ���
	ld b,1              ; register 1.			���W�X�^1�B
	call setreg         ; set register.			���W�X�^��ݒ肵�܂�

	ei                  ; turn interrupts on.		���荞�݂��I���ɂ��܂��B

	xor a	; �O�̂��ߏ�����





	; BANK�؂�ւ�
	ld a, :logo_bg_tiles
	ld (BANK_SWITCH), a

	; �w�i�̕ύX
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




	; TODO �p���b�g�Q�̃t�F�[�h�A�E�g�ɑΉ����Ă��Ȃ��̂ŁA
	; �p���b�g�Q
	ld hl,$c020
	call vrampr		; prepare vram.			VRAM���������܂��B
	ld hl,kuro1_palette	; background palette.		�w�i�p���b�g�B
	ld bc,32		; 32�Œ�
	call vramwr		; set background palette.	�w�i�p���b�g��ݒ肵�܂��B

	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,kuro1_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ld a, kuro_tilemap
	ld hl,address_kuro_map
	call tilemap48

	; ���W
	ld a, 62
	ld hl,address_kuro_x
	call x_view48

	ld a, 72
	ld hl,address_kuro_y
	call y_view48

	call ldsat          ; �X�v���C�g�̔��f

	; �t�F�[�h�C��
	ld hl, logo_bg_palette
	CALL FadeInScreen

	ld a, 0
	ld (anime), a
	ld (anime2), a


logo_loop:
	halt			; start main loop with vblank.	���C�����[�v��vblank�ŊJ�n���܂��B
				; HALT �� ���荞��/���Z�b�g������܂ŁCNOP �����s���܂�
				; NOP�͉������Ȃ����߂Ɍ����܂����C���ۂ̓������[���疽�߂�ǂݍ��݃v���O�����J�E���^�[���ЂƂi�߂Ă��܂��D

	; �X�^�[�g�{�^�������������ǂ���
	in     a,($00)
	and    %10000000
	jp z, logo_end


	; �A�j���[�V����
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

	call ldsat          ; �X�v���C�g�̔��f

	jp logo_loop


logo_anime_1:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B

	ld hl,kuro1_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ret

logo_anime_2:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B

	ld hl,kuro2_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ret

logo_anime_3:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B

	ld hl,kuro3_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ret

logo_anime_4:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B

	ld hl,kuro4_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ret

logo_anime_5:
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B

	ld hl,kuro5_tiles
	ld bc,36*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ret








logo_end:
	
	; �t�F�[�h�A�E�g
	ld hl, logo_bg_palette
	CALL FadeOutScreen
	
	; �X�v���C�g�N���A
	call sprite_clear
	call ldsat
	
	jp title_init






; ===============================================================
; �^�C�g��
; ===============================================================




title_init:

	; �Ȃ̕ύX
	call PSGStop
	ld a, :opening_bgm
	ld hl,opening_bgm
	call PSGPlay

	; BANK�؂�ւ�
	ld a, :bg_tiles
	ld (BANK_SWITCH), a

	; �w�i�̕ύX
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

	; BANK�؂�ւ�
	ld a, :font_palette
	ld (BANK_SWITCH), a

	; PUSH START
	ld hl,$0200
	call vrampr
	ld hl, text1
	ld a,10
	call font_set

	ld hl,$3AD6	; ���W
	call vrampr
	ld hl,font_tilemap2
	ld bc,10*2		; each is 2 bytes.
	call vramwr


	; �{�[���Ȃ������Q�[���Q���_
	ld hl,$0400
	call vrampr
	ld hl, text02
	ld a,12
	call font_set

	ld hl,$3994	; ���W
	call vrampr
	ld hl,font_tilemap3
	ld bc,12*2		; each is 2 bytes.
	call vramwr

	; �{�[���Ȃ������Q�[��
	ld hl,$0600
	call vrampr
	ld hl, text2
	ld a,12
	call font_set

	ld hl,$39D4	; ���W
	call vrampr
	ld hl,font_tilemap4
	ld bc,12*2		; each is 2 bytes.
	call vramwr

	; ��
	ld hl,$0800
	call vrampr
	ld hl, text3
	ld a,12
	call font_set

	ld hl,$3A14	; ���W
	call vrampr
	ld hl,font_tilemap5
	ld bc,12*2		; each is 2 bytes.
	call vramwr


	; BANK�؂�ւ�
	ld a, :bg_tiles
	ld (BANK_SWITCH), a


	; �X�v���C�g�̓o�^

	; �v���C���[�̕`��
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,player1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	; �^�C���}�b�v
	ld a, player_tilemap
	ld hl, address.player.map
	call tilemap_3x4
	
	; ���W
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



	; �G�l�~�[�̕`��
	ld hl,$2200
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,enemy1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	; �^�C���}�b�v
	ld a, enemy_tilemap
	ld hl,address.enemy.map
	call tilemap_3x4
	
	; ���W
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

	call ldsat          ; �X�v���C�g�̔��f

	; �t�F�[�h�C��
	ld hl, bg_palette
	CALL FadeInScreen

	; TODO �p���b�g�Q�̃t�F�[�h�A�E�g�ɑΉ����Ă��Ȃ��̂ŁA
	; �p���b�g�Q
	ld hl,$c020
	call vrampr		; prepare vram.			VRAM���������܂��B
	ld hl,player1_palette	; background palette.		�w�i�p���b�g�B
	ld bc,32		; 32�Œ�
	call vramwr		; set background palette.	�w�i�p���b�g��ݒ肵�܂��B




title_loop:
	halt			; start main loop with vblank.	���C�����[�v��vblank�ŊJ�n���܂��B
				; HALT �� ���荞��/���Z�b�g������܂ŁCNOP �����s���܂�
				; NOP�͉������Ȃ����߂Ɍ����܂����C���ۂ̓������[���疽�߂�ǂݍ��݃v���O�����J�E���^�[���ЂƂi�߂Ă��܂��D

	; BGM�̍Đ�
	call PSGFrame


	; �A�j���[�V����
	ld a, (anime)
	add a, 1
	ld (anime), a
	cp 30
	call z, animation2
	cp 60
	call z, animation1


	; �X�^�[�g�{�^�������������ǂ���
	in     a,($00)
	and    %10000000
	jp z, title_end

	jp title_loop

title_end:

	jp game_init


game_init:

	; �A�j���[�V����������
	ld a, 0
	ld (anime), a

	; �w�i�̕ύX
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
	; �{�[��
	; =============================

	; �{�[�����^�C���ɃZ�b�g
	ld hl,$2400
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,ball_tiles
	ld bc,1*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	; �^�C���}�b�v
	ld a, ball_tilemap
	ld hl, address.ball.map
	call tilemap_1x1
	
	; ���W
	ld a, 160
	ld (ball.x), a
	ld a, 80
	ld (ball.y), a


	; �t�F�[�h�C��
	ld hl, bg_palette
	CALL FadeInScreen

	; TODO �p���b�g�Q�̃t�F�[�h�A�E�g�ɑΉ����Ă��Ȃ��̂ŁA
	; �p���b�g�Q
	ld hl,$c020
	call vrampr		; prepare vram.			VRAM���������܂��B
	ld hl,player1_palette	; background palette.		�w�i�p���b�g�B
	ld bc,32		; 32�Œ�
	call vramwr		; set background palette.	�w�i�p���b�g��ݒ肵�܂��B


	; �E�������ǂ����̃t���O
	ld a, 0
	ld (pick_up), a

game_loop:
	halt			; start main loop with vblank.	���C�����[�v��vblank�ŊJ�n���܂��B
				; HALT �� ���荞��/���Z�b�g������܂ŁCNOP �����s���܂�
				; NOP�͉������Ȃ����߂Ɍ����܂����C���ۂ̓������[���疽�߂�ǂݍ��݃v���O�����J�E���^�[���ЂƂi�߂Ă��܂��D

	; BGM�̍Đ�
	call PSGFrame



	; �A�j���[�V����
	ld a, (anime)
	add a, 1
	ld (anime), a
	cp 10
	call z, animation2
	cp 20
	call z, animation1




	; �L�[����
	call getInput       ; read controller port.

	; ��{�^��
	ld a,(input)        ; read input from ram mirror.
	bit 0,a             ; is right key pressed?
	call z,player_up

	; ���{�^��
	ld a,(input)        ; read input from ram mirror.
	bit 1,a             ; is right key pressed?
	call z,player_down

	; ���{�^��
	ld a,(input)        ; read input from ram mirror.
	bit 2,a             ; is right key pressed?
	call z,player_left

	; �E�{�^��
	ld a,(input)        ; read input from ram mirror.
	bit 3,a             ; is right key pressed?
	call z,player_right



	; �G�l�~�[�̎v�l












	; �{�[�����E�������ǂ���
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




	; �v���C���[�̕`��
	ld a, (player.x)
	ld hl,address.player.x
	call x_view_3x4

	ld a, (player.y)
	ld hl,address.player.y
	call y_view_3x4


	; �G�l�~�[�̕`��
	ld a, (enemy.x)
	ld hl,address.enemy.x
	call x_view_3x4

	ld a, (enemy.y)
	ld hl,address.enemy.y
	call y_view_3x4

	; �{�[���̕`��
	ld a, (ball.x)
	ld hl,address.ball.x
	call x_view_1x1

	ld a, (ball.y)
	ld hl,address.ball.y
	call y_view_1x1


	call ldsat          ; �X�v���C�g�̔��f


	jp game_loop



animation1:
	; �X�v���C�g�̕ύX
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,player1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ld hl,$2200
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,enemy1_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	xor a
	ld (anime), a

	ret

animation2:
	; �X�v���C�g�̕ύX
	ld hl,$2000
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,player2_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

	ld hl,$2200
	call  vrampr		; prepare vram at the above address.	��L�̃A�h���X��vram���������܂��B
	ld hl,enemy2_tiles
	ld bc,16*32		; 16 tiles, each tile is 32 bytes.	60�^�C���B�e�^�C����32�o�C�g�ł��B
	call vramwr		; write characters to vram.		vram�ɕ������������݂܂��B

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
