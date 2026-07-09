        ; Game behavior / bugfixes

        ; If nonzero, a grenade exploding a partially visible mine will no longer lock up the game in an endless loop,
        ; but the game binary will also no longer be byte-identical

GRENADE_HANG_FIX = 0

        ; If nonzero, border will be flashed if enemy custom code with illegal type is attempted to be run.
        ; Total code size is retained the same

ILLEGAL_ENEMY_TYPE_CHECK = 0

        ; If nonzero, lives are not decremented

INFINITE_LIVES_CHEAT = 0

        ; If nonzero, extra weapons have infinite shots to aid in testing

INFINITE_SHOTS_CHEAT = 0

        ; If nonzero, player will be invulnerable to aid in testing. Note that this disables collisions entirely;
        ; a bazooka shot that explodes and tries to kill the player will remain indefinitely on screen in the final
        ; fights and prevent progress

INVULNERABILITY_CHEAT = 0

        ; Zeropage variables

irqCounter = $02
sortMoveEndCmp = $03
sortSpriteStoreY = $04
sortSpriteStoreX = $05
sortSprNumReorders = $06
sprIrqHWIndex = $08
sprIrqYCheck = $09
sprIrqIndex = $0A
sprIrqYStore = $0C
screenPtrLo = $0F
screenPtrHi = $10
srcPtrLo = $11
srcPtrHi = $12
columnSrcLo = $13
columnSrcHi = $14
columnBase = $16
columnSrcBase = $17
columnAdd = $18
stagePosLSB = $1B
stagePosMSB = $1C
irqSpriteOrder = $20
spriteOrder = $35
irqSpriteY = $4A
spriteY = $5F
playerLowerY = $60
enemyUpperY = $61
dogY = $62
enemyLowerY = $67
bulletY = $6D
extraPickupY = $73
irqSpriteXMSB = $74
irqSpriteX = $89
screenRowPtrs = $A0
screenRowPtrsHi = $A1
colorRowPtrs = $C0
colorRowPtrsHi = $C1

        ; Music/sound playroutine zeropage variables

chn1Lo = $E6
chn1Hi = $E7
chn2Lo = $E8
chn2Hi = $E9
chn3Lo = $EA
chn3Hi = $EB
chn1Timer = $EC
chn2Timer = $ED
chn3Timer = $EE
chn1StackPtr = $EF
chn2StackPtr = $F0
chn3StackPtr = $F1
chn1Trans = $F2
chn2Trans = $F3
chn3Trans = $F4
chn1MusicFlag = $F5
chn2MusicFlag = $F6
chn3MusicFlag = $F7
chn1SoundFlag  = $F8
chn2SoundFlag  = $F9
chn3SoundFlag  = $FA
playRoutineTemp = $FB
playRoutineLo = $FC
playRoutineHi = $FD

        ; Variables

staticEnemySpawnFlag = $0144
spriteX = $0180
playerLowerX = $0181
enemyUpperX = $0182
dogX = $0183
enemyLowerX = $0188
bulletX = $018E
weaponPickupX = $0194
spriteXMSB = $0195
playerLowerXMSB = $0196
enemyUpperXMSB = $0197
dogXMSB = $0198
enemyLowerXMSB = $019D
bulletXMSB = $01A3
weaponPickupXMSB = $01A9
spriteColor = $01AA
playerLowerColor = $01AB
enemyUpperColor = $01AC
dogColor = $01AD
enemyLowerColor = $01B2
bulletColor = $01B8
weaponPickupColor = $01BE
spriteFrame = $01BF
playerFrameLower = $01C0
enemyUpperFrame = $01C1
dogFrame = $01C2
enemyLowerFrame = $01C7
bulletFrame = $01CD
weaponPickupFrame = $01D3
flameDetachedTimer = $0200
playerJumpArcIndex = $0201
lastScrollSpeed = $0202
playerBaseY = $0203
bulletYBase = $0204
bulletJumpArcIndex = $020A
bulletYDir = $0210
bulletLastChar = $0216
bulletTimer = $021C
bulletExploded = $0222
enemyClimbingCopy = $0228
dogJumping = $022E
scrollSpeed = $0234
playerJumpControls = $0235
platformTemp = $0236
truckAnimTimer = $0238
playerFacingDir = $0239
spawnRetryCount = $023A
enemyHorizMove = $023B
playerJumping = $0241
bulletOffset = $0242
enemyJumping = $0243
playerAnimState = $0249
plrAnimOffsetIndex = $024A
extraWeaponFireFlag = $024B
stageEndFightActive = $024C
stageEndReached = $024D
truckInitFlag = $024E
firstStageEndCounter = $024F
initialDrawColumn = $0250
numAliveGyros = $0251
bulletActive = $0252
bulletXDir = $0258
bulletXSpeed = $025E
collectedExtraWeapon = $0264
activeExtraWeapon = $0265
extraWeaponShotsLeft = $0266
weaponPickupType = $0267
weaponPickupRestFlag = $0268
nextSpawnTblIndex = $0269
playerHitCheckX = $026A
hitPointX = $026B
playerHitCheckY = $026E
hitPointY = $026F
enemyTouchBoundHigh = $0272
knifeHitBoundHigh = $0273
enemyTouchBoundLow = $0274
knifeHitBoundLow = $0275
enemyLastControls = $0276
dogActive = $027C
enemyClimbing = $0282
enemyJumpPlatformHeight = $0288
enemyPlatformHeight = $028E
enemyActive = $0294
enemyTimer = $029A
enemyLongLadderClimb = $02A0
enemyAuxTimer = $02A6
enemyFireFlag = $02AC
enemyDying = $02B2
dogDead = $02B3
dogHit = $02B9
enemyStaticIndex = $02BE
endFightResetFlag = $02C4
numEnemies = $02C8
platformEnemyCount = $02C9
midPlatformCount = $02CA
topPlatformCount = $02CB
staticSpawnFlag = $02CC
spawnEnemyTimer = $02CD
spawnEnemyType = $02D3
spawnEnemyFlag = $02D9
enemyHit = $02DF
playerFalling = $02E5
playerKnifeTimer = $02E6
playerJumpInhibit = $02E7
playerLastUp = $02E8
parachuteYGlideFlag = $02EA
playerPlatformHeight = $02EB
playerRunSpeed = $02EC
enemyRunSpeed = $02ED
playerRunSubPixel = $02F3
enemyRunSubPixel = $02F4
plrFallSpeedSubPixel = $02FA
enemyJumpSpeed = $02FB
playerYSubPixel = $0301
enemyJumpSubPixel = $0302
playerRunAnimTimer = $0308
enemyRunAnimTimer = $0309
playerRunFrame = $030F
enemyRunAnimFrame = $0310
frameSyncFlag = $0316
scrollX = $0317
playerCoarseX = $0318
charAtPlayer = $0319
charBelowPlayer = $031A
dogSpawnTimer = $031B
playerControls = $031C
joystickBits = $031D
playerLastFire = $031E
fighterJetIndex = $031F
idleTimer = $0320
idleTimerLSB = $0321
parachuteKillFlag = $0322
charTypeBelowPlayer = $0323
charTypeBelowEnemy = $0324
charTypeAtEnemy = $032A
tempStore = $0330
knifeHitTemp = $0331
charTypeAtPlayer = $0332
playerClimbing = $0333
playerClimbingCopy = $0334
newColumnFlag = $0335
screenShiftFlag = $0336
enemyType = $0337
bulletType = $033D
parachuteActiveFlag = $0343
enemyTimerActive = $0344
enemyFalling = $034A
gyroYPathDir = $0350
secondGyroYPathDir = $0351
gyrosAliveFlag = $0352
gyroY = $0353
enemyCoarseX = $0355
dogCoarseX = $0356
truckCoarseX = $0357
bulletCoarseX = $0361
weaponPickupCoarseX = $0367
endFightEnemiesLeft = $0369
lastScrollX = $036A
enemyJumpArcIndex = $036B
enemyBaseY = $0371
enemyControls = $0377
dogDir = $0378
charAtEnemy = $037D
charBelowEnemy = $0383
charUnderIntroGuard1 = $0387
charUnderIntroGuard2 = $0388
temp = $0389
tempStoreX = $038A
bulletIndex = $038B
temp2 = $038C
tempStoreY = $038D
tempStoreY2 = $038E
gyroCoarseX = $038F
gyroXSpeed = $0391
gyroYPathIndex = $0393
gyroBaseY = $0395
gyroSpawnTimer = $0397
gyroAnimFrame = $0398
parachuteXSpeed = $0399
haltPlayerFlag = $039A
dogJumpArcIndex = $039B
dogBaseY = $039F
enemyCrawlTimer = $03A3
gameTimer = $03A9
nextDogHandlerDir = $03AF
dogHandlerDelayTimer = $03B0
stage = $03B1
spawnTblIndexMod = $03B2
lives = $03B3
score = $03B4
nextExtraLifeScore = $03B7
scoreAdd = $03BA

        ; Screens and the color RAM

screen = $4000
statusScreen = $C400
colorRam = $D800