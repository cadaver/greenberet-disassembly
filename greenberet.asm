        ; Variable & zeropage variable defines

		.INCLUDE defines.asm

        ; Main game code and data at $03BF-$3FFF    

        .INCLUDE screendata.asm
        .INCLUDE mainloop.asm
        .INCLUDE fighterjet.asm
        .INCLUDE weaponpickup.asm
        .INCLUDE enemyscoring.asm
        .INCLUDE playerenemycollision.asm       
        .INCLUDE stageendfights.asm
        .INCLUDE stagecompleterestart.asm
        .INCLUDE weaponbulletupdate.asm
        .INCLUDE truckanimation.asm
        .INCLUDE spawnenemies.asm
        .INCLUDE playerenemyupdate.asm
        .INCLUDE enemyspecificcode.asm
        .INCLUDE scrollandframesync.asm
        .INCLUDE titleoutroscreens.asm
        .INCLUDE irqgameupdate.asm
        .INCLUDE drawstageandmines.asm
        .INCLUDE playroutinecalls.asm

        ; Game entry point and video bank data at $4000-$7FFF

		.INCLUDE videobank.asm

        ; Stage data from $8000 onwards

		.INCLUDE stagedata.asm

        ; Additional code and data from $C257 onwards

        .INCLUDE statusdisplay.asm
        .INCLUDE spritemultiplexer.asm
        .INCLUDE textprinting.asm
        .INCLUDE dogandtextdata.asm
        .INCLUDE irqhandlerspritesort.asm
        .INCLUDE screenprinting.asm
        .INCLUDE underiodata.asm

        ; Playroutine and music/sound effect data at $E000		

		.INCLUDE playroutine.asm
        .INCLUDE musicdata.asm

        ; Final extra code and data at the end of memory

		.INCLUDE enemybulletcollision.asm
        .INCLUDE swapgraphics.asm
