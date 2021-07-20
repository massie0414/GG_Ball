;=====================
; アセット
;=====================

.section "assets_img" free

; logo
logo_bg_tiles	.include "assets\logo_bg (tiles).inc"
logo_bg_tilemap	.include "assets\logo_bg (tilemap).inc"
logo_bg_palette	.include "assets\logo_bg (palette).inc"

kuro1_tiles	.include "assets\kuro1 (tiles).inc"
kuro1_tilemap	.include "assets\kuro1 (tilemap).inc"
kuro1_palette	.include "assets\kuro1 (palette).inc"

kuro2_tiles	.include "assets\kuro2 (tiles).inc"
kuro2_tilemap	.include "assets\kuro2 (tilemap).inc"
kuro2_palette	.include "assets\kuro2 (palette).inc"

kuro3_tiles	.include "assets\kuro3 (tiles).inc"
kuro3_tilemap	.include "assets\kuro3 (tilemap).inc"
kuro3_palette	.include "assets\kuro3 (palette).inc"

kuro4_tiles	.include "assets\kuro4 (tiles).inc"
kuro4_tilemap	.include "assets\kuro4 (tilemap).inc"
kuro4_palette	.include "assets\kuro4 (palette).inc"

kuro5_tiles	.include "assets\kuro5 (tiles).inc"
kuro5_tilemap	.include "assets\kuro5 (tilemap).inc"
kuro5_palette	.include "assets\kuro5 (palette).inc"

bg_tiles	.include "assets\bg (tiles).inc"
bg_tilemap	.include "assets\bg (tilemap).inc"
bg_palette	.include "assets\bg (palette).inc"

player1_tiles	.include "assets\player1 (tiles).inc"
player1_tilemap	.include "assets\player1 (tilemap).inc"
player1_palette	.include "assets\player1 (palette).inc"

player2_tiles	.include "assets\player2 (tiles).inc"
player2_tilemap	.include "assets\player2 (tilemap).inc"
player2_palette	.include "assets\player2 (palette).inc"

enemy1_tiles	.include "assets\enemy1 (tiles).inc"
enemy1_tilemap	.include "assets\enemy1 (tilemap).inc"
enemy1_palette	.include "assets\enemy1 (palette).inc"

enemy2_tiles	.include "assets\enemy2 (tiles).inc"
enemy2_tilemap	.include "assets\enemy2 (tilemap).inc"
enemy2_palette	.include "assets\enemy2 (palette).inc"

ball_tiles	.include "assets\ball (tiles).inc"
ball_tilemap	.include "assets\ball (tilemap).inc"
ball_palette	.include "assets\ball (palette).inc"

.equ kuro_tilemap     $00

.equ address_kuro_y   $c000
.equ address_kuro_x   $c080
.equ address_kuro_map $c081

.ends
