IF !DEF(ENEMY_INC)
	DEF ENEMY_INC = 1


				RSRESET
	DEF Enemy_ID RB   1 ;if 0, free slot, else, describes the enemy that is occupying the slot
	DEF Enemy_PosX RB 2 ;speaks for itself
	DEF Enemy_PosY RB 2 ;speaks for itself
	DEF EnemyAnimCnt RB 1 ;frame counter for animation handling
	DEF EnemyTileID RB 1 ;current tile ID for the enemy in question
	DEF EnemyTileAttribute RB 1 ;tile attribute of the enemy, mostly for palette swapping and tileflipping
	DEF Enemy_Size RB 0 ;size of the struct

	DEF ENEMY_ID_NONE = 0
	DEF ENEMY_ID_ROLLER = 1
	DEF ENEMY_ID_BIRD = 2
	DEF ENEMY_ID_FROG = 3
	DEF ENEMY_ID_GHOST = 4
ENDC
