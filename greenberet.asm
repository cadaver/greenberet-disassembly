        ; Variable & zeropage variable defines

        .INCLUDE "src/defines.asm"

        ; Main game code and data at $03BF-$3FFF

        .INCLUDE "data/screendata.asm"
        .INCLUDE "src/mainloop.asm"
        .INCLUDE "src/fighterjet.asm"
        .INCLUDE "src/weaponpickup.asm"
        .INCLUDE "src/enemyscoring.asm"
        .INCLUDE "src/playerenemycollision.asm"
        .INCLUDE "src/stageendfights.asm"
        .INCLUDE "src/stagecompleterestart.asm"
        .INCLUDE "src/weaponbulletupdate.asm"
        .INCLUDE "src/truckanimation.asm"
        .INCLUDE "src/spawnenemies.asm"
        .INCLUDE "src/playerenemyupdate.asm"
        .INCLUDE "src/enemyspecificcode.asm"
        .INCLUDE "src/enemyremoveandclimb.asm"
        .INCLUDE "src/scrollandframesync.asm"
        .INCLUDE "src/titleoutroscreens.asm"
        .INCLUDE "src/irqgameupdate.asm"
        .INCLUDE "src/drawstageandmines.asm"
        .INCLUDE "src/playroutinecalls.asm"

        ; Game entry point and video bank data at $4000-$7FFF

        .INCLUDE "src/entrypoint.asm"
        .INCLUDE "data/videobankdata.asm"

        ; Stage data from $8000 onwards

        .INCLUDE "data/stagedata.asm"

        ; Additional code and data from $C257 onwards

        .INCLUDE "src/statusdisplay.asm"
        .INCLUDE "src/spritemultiplexer.asm"
        .INCLUDE "src/textprinting.asm"
        .INCLUDE "data/dogandtextdata.asm"
        .INCLUDE "src/irqhandlerspritesort.asm"
        .INCLUDE "src/screenprinting.asm"
        .INCLUDE "data/underiodata.asm"

        ; Playroutine and music/sound effect data at $E000

        .INCLUDE "src/playroutine.asm"
        .INCLUDE "data/musicdata.asm"

        ; Final extra code and data at the end of memory

        .INCLUDE "src/enemybulletcollision.asm"
        .INCLUDE "src/swapgraphics.asm"
