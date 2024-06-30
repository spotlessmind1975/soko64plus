''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' SOKO64+
''
'' Original source for Commodore 64 by Emanuele Feronato
'' Ported to other platforms by Marco Spedaletti
''
'' Official binary distribution of SOKO64 at:
'' https://triqui.itch.io/soko64
''
'' Official binary distribution of SOKO64+ at:
'' https://spotlessmind1975.itch.io/soko64plus
''
'' This version repository at:
'' https://github.com/spotlessmind1975/soko64plus
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''---------------------------------------------------------------------------
''' INITIALIZATION PHASE
'''---------------------------------------------------------------------------

' The first pragma we use is for those systems that have a limited
' configurable palette: in this way, we are going to deactivate the
' palette preservation, since we are using images that have all
' a precalculated palette (and it saves some memory, too!).

DEFINE PALETTE NOT PRESERVE

' Then, it is necessary to apply some techniques to reduce the memory actually 
' used, so that the game can run even on rather limited platforms, 
' such as ColecoVision.

' First, let's proceed to reduce the space occupied by dynamic strings. 
' In ugBASIC this space, despite being dynamic, is statically allocated 
' and occupies a certain memory space. With this pragma we tell ugBASIC 
' that we will never use more than 32 bytes to manage (dynamic) strings. 
' Static strings, such as those in quotes, don't count.

DEFINE STRING SPACE 32

' We also reduce the number of (dynamic) strings that can exist at any 
' given time, to a maximum of 12.

DEFINE STRING COUNT 12

' This other pragma asks ugBASIC to reduce the footprint of the
' generated code, excluding everything that is not used except 
' that which is valid for the (only) graphics mode that will be used. 
' In other words, with this command it will not be possible to use 
' different graphics modes in the same program. On the other hand, 
' you will get a fair improvement in the memory occupation of the code.

DEFINE SCREEN MODE UNIQUE

' We enable the "bitmap" graphics mode. This is the mode in which 
' each individual pixel can be addressed individually, via primitive 
' commands, such as those related to drawing entire images.

BITMAP ENABLE

' We set the border color to black, at least for those targets for 
' which this instruction makes sense. Since ugBASIC is an isomorphic 
' language, it does not provide an abstraction of the concept of 
' "border". Therefore, if the border exists, it will be colored, 
' otherwise this statement corresponds to a "no operation".

COLOR BORDER BLACK

' This is the array that defines all 64 levels. Each level is 
' described by a matrix of 8x8 cells. The original author 
' introduced an optimization mechanism, which consists in 
' representing only 6x6 boxes, given that all the perimeter 
' ones are always and only walls. In this version of the source, 
' the definition of the levels is done "in line" with the source. 
' The other version shows how this definition can be read 
' from an external file. Moreover, the entire array is defined
' as READ ONLY, so that it will not occupy RAM space.
' In this definition, the first level is explicitly showed.

DIM levels(2304) AS BYTE = #{_
	_
	0,0,1,1,1,1,_
	0,0,1,1,1,1,_
	0,0,0,0,0,0,_
	1,4,2,1,3,0,_
	0,0,0,1,0,0,_
	0,0,0,1,1,1,_
	_
1,0,0,0,0,1,1,3,0,2,0,1,0,0,4,0,0,1,0,3,1,2,0,1,0,0,1,1,1,1,1,1,1,1,1,1,_
2,0,1,1,1,1,2,0,1,1,1,1,4,3,0,0,1,1,0,3,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,_
2,0,4,0,0,1,0,0,3,3,0,1,1,1,0,2,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,_
1,1,0,0,1,1,0,0,5,4,1,1,0,0,3,2,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,1,1,1,1,_
0,0,1,1,1,1,0,4,1,1,1,1,2,3,1,1,1,1,0,0,0,0,1,1,2,3,1,0,1,1,1,0,0,0,1,1,_
1,0,0,0,0,1,0,0,1,1,0,1,0,3,2,3,2,0,1,0,1,0,0,0,1,0,4,0,1,1,1,1,1,1,1,1,_
1,1,0,0,1,1,1,1,3,2,4,0,0,0,0,1,0,0,0,0,3,2,0,1,0,0,1,0,0,1,1,1,1,0,0,1,_
1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,1,2,1,0,0,3,3,2,1,1,0,0,0,4,1,1,1,1,1,1,1,_
1,0,0,0,1,1,1,3,1,2,1,1,0,0,0,0,1,1,0,3,1,2,0,1,1,0,4,0,0,1,1,1,1,0,0,1,_
0,0,0,1,0,0,0,0,2,0,0,0,1,3,1,1,0,0,0,4,2,1,0,0,0,3,0,0,0,0,1,1,1,1,0,0,_
2,2,6,1,1,1,0,3,3,1,1,1,1,3,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,1,1,_
1,0,0,0,1,1,1,0,0,0,1,1,1,1,0,0,1,1,0,3,3,3,0,1,0,2,6,2,0,1,1,1,1,1,1,1,_
0,0,1,1,1,1,0,0,0,0,1,1,0,3,2,0,1,1,1,0,5,0,1,1,1,3,2,0,1,1,1,0,4,1,1,1,_
1,0,0,0,0,1,1,0,1,0,0,1,2,5,1,0,0,1,2,0,1,0,1,1,4,3,3,0,0,0,0,0,1,0,0,0,_
1,0,0,0,0,1,1,0,2,2,2,1,0,3,3,3,0,1,0,4,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,_
0,2,2,0,0,1,0,2,4,3,0,1,1,0,3,3,0,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,_
0,4,1,1,1,1,0,0,1,1,1,1,3,3,3,0,0,1,2,2,2,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,_
1,1,0,6,0,1,1,1,0,5,0,1,0,0,3,5,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,_
0,0,1,1,1,1,0,0,1,1,1,1,0,0,3,0,0,1,1,3,5,2,0,1,0,0,2,0,1,1,0,0,4,0,1,1,_
0,0,0,0,0,1,2,1,0,1,0,1,0,3,3,2,0,1,2,0,0,1,1,1,0,1,3,1,1,1,0,0,4,1,1,1,_
1,0,0,0,0,1,1,0,2,2,2,1,0,3,3,0,3,1,4,0,1,0,0,1,0,0,1,0,0,1,1,1,1,1,1,1,_
1,1,0,0,1,1,2,0,3,0,3,0,4,1,0,0,1,0,0,1,3,2,2,0,0,0,0,1,1,1,1,1,1,1,1,1,_
1,1,0,0,1,1,1,2,3,0,1,1,0,3,2,4,1,1,0,2,3,0,1,1,0,0,1,1,1,1,0,0,1,1,1,1,_
0,0,0,1,1,1,0,0,0,1,1,1,1,3,3,0,3,0,1,2,2,0,2,0,1,0,0,1,1,1,1,4,0,1,1,1,_
1,0,0,1,1,1,0,0,0,1,1,1,0,5,2,4,0,1,1,3,5,0,0,1,0,0,0,1,1,1,0,0,0,1,1,1,_
1,1,0,0,1,1,1,1,3,0,1,1,0,6,5,2,0,1,0,0,3,0,0,1,0,0,0,1,1,1,0,0,0,1,1,1,_
1,1,0,0,0,1,1,0,0,1,0,1,1,6,3,5,5,1,0,0,0,1,0,1,0,0,0,0,0,1,1,1,1,1,1,1,_
0,0,1,0,0,0,0,2,0,0,2,2,0,0,0,1,1,1,0,3,3,3,0,1,1,1,4,0,0,1,1,1,1,1,1,1,_
1,1,0,0,1,1,0,0,0,0,1,1,0,3,0,3,0,1,0,0,1,3,4,1,2,2,2,0,1,1,1,1,1,1,1,1,_
1,0,0,1,1,1,1,0,0,0,0,0,1,3,2,2,0,2,0,0,1,1,4,1,0,3,3,0,0,1,0,0,0,0,0,1,_
0,2,1,1,1,1,0,2,1,1,1,1,3,0,0,3,4,0,0,0,0,3,0,0,2,0,1,1,1,1,1,1,1,1,1,1,_
1,1,1,1,4,0,1,1,0,0,0,0,0,3,3,1,2,0,2,0,0,0,0,1,0,3,0,1,0,1,1,1,0,0,2,1,_
0,0,0,1,1,1,0,1,0,1,1,1,0,0,0,1,1,1,5,6,3,5,0,1,0,0,0,0,0,1,1,1,1,0,0,1,_
1,1,1,0,0,1,0,0,2,3,0,1,0,0,2,3,4,1,1,1,2,3,1,1,1,1,0,0,1,1,1,1,0,0,1,1,_
0,0,1,1,1,1,0,3,2,0,1,1,0,0,3,2,1,1,1,3,2,0,1,1,1,4,0,1,1,1,1,0,0,1,1,1,_
1,1,1,0,0,1,0,0,1,0,0,1,0,0,3,3,3,0,4,2,2,0,2,0,1,1,1,0,0,1,1,1,1,1,1,1,_
0,0,1,1,1,1,0,2,2,0,4,0,0,3,0,1,1,0,1,0,0,1,1,0,1,3,2,0,3,0,1,0,0,1,1,1,_
1,1,0,0,1,1,1,1,0,3,1,1,0,0,3,2,3,0,0,0,2,4,2,0,1,0,0,0,1,1,1,1,1,1,1,1,_
0,0,0,0,1,1,0,0,2,0,0,1,1,3,5,3,0,1,1,0,2,4,1,1,1,1,0,0,1,1,1,1,1,1,1,1,_
1,1,0,2,0,1,1,1,3,2,0,1,0,0,0,2,0,1,0,3,3,0,0,1,1,0,4,1,1,1,1,1,1,1,1,1,_
0,0,0,0,1,1,4,3,3,0,1,1,1,3,2,2,1,1,1,0,2,0,1,1,1,1,0,0,1,1,1,1,1,1,1,1,_
0,0,0,0,0,1,0,1,3,2,0,1,0,0,3,2,1,1,1,1,3,2,1,1,1,1,4,0,1,1,1,1,0,0,1,1,_
1,1,0,4,1,1,0,0,5,0,1,1,0,0,5,2,0,1,0,0,5,3,0,1,0,0,0,1,1,1,1,1,1,1,1,1,_
1,1,1,0,0,0,1,1,1,4,1,0,0,0,0,0,3,0,0,1,2,2,2,1,0,3,0,1,3,1,1,1,0,0,0,1,_
1,0,0,1,1,1,0,0,0,1,1,1,0,0,5,3,4,0,0,0,2,5,0,0,1,1,0,0,1,1,1,1,1,1,1,1,_
1,1,0,0,1,1,1,1,4,0,1,1,1,1,3,5,1,1,0,0,5,2,0,0,0,0,0,0,0,0,0,0,1,1,1,1,_
0,0,1,1,1,1,0,2,3,2,1,1,0,0,3,0,0,0,1,1,0,0,4,2,1,1,3,0,1,1,1,1,0,0,1,1,_
1,2,0,0,2,1,0,2,0,1,0,1,0,0,0,3,0,1,0,3,1,3,1,1,1,0,4,0,1,1,1,1,1,1,1,1,_
0,0,2,0,0,1,0,1,5,1,0,1,5,0,3,0,0,1,0,0,4,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,_
2,0,0,1,1,1,2,1,0,1,1,1,0,0,0,3,0,1,0,3,3,2,0,1,0,0,4,1,1,1,1,1,1,1,1,1,_
0,0,0,1,1,1,0,1,0,1,1,1,0,1,6,0,1,1,0,3,5,3,0,1,0,0,2,0,0,1,1,1,1,0,0,1,_
1,1,0,0,1,1,1,1,0,2,1,1,1,1,3,0,3,0,0,4,0,3,1,0,0,1,2,2,0,0,0,0,0,1,1,1,_
1,1,0,0,1,1,0,0,0,5,1,1,0,1,0,2,1,1,0,0,4,3,1,1,1,1,0,5,0,1,1,1,0,0,0,1,_
1,1,1,0,0,1,0,0,1,3,2,1,0,0,0,3,2,1,0,0,1,3,2,1,1,0,1,0,0,1,1,0,0,4,0,1,_
1,0,0,1,1,1,1,3,0,0,0,1,1,4,3,2,0,1,1,3,1,2,1,1,0,0,0,2,1,1,0,0,0,0,1,1,_
1,1,0,0,1,1,1,0,3,0,1,1,0,2,3,2,1,1,0,0,3,2,0,1,1,1,4,0,0,1,1,1,1,0,0,1,_
1,1,1,1,0,0,1,0,4,0,0,0,0,5,5,5,2,0,0,0,3,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,_
1,1,0,0,1,1,1,1,0,0,0,0,0,3,3,5,0,0,0,2,4,2,0,1,0,0,1,1,1,1,1,1,1,1,1,1,_
1,1,0,0,1,1,1,1,2,4,2,0,0,0,3,2,1,0,0,0,0,3,0,0,1,1,1,0,3,1,1,1,1,0,0,1,_
1,0,2,0,1,1,1,4,0,3,1,1,0,0,5,0,0,0,0,5,0,5,0,0,1,0,0,0,1,1,1,1,1,1,1,1,_
1,0,0,0,1,1,1,3,1,0,1,1,0,4,0,0,1,1,0,1,0,2,1,1,2,3,3,2,0,1,1,1,0,0,0,1,_
0,0,0,0,0,1,0,1,0,1,0,1,0,2,0,3,2,0,1,1,3,5,3,0,1,1,0,2,0,1,1,1,1,4,0,1,_
1,0,0,0,0,1,1,3,1,1,2,1,1,0,1,1,2,1,0,0,0,3,2,0,0,3,0,0,4,0,1,1,0,0,1,1_
} READ ONLY

' The ugBASIC language, like other BASICs, does not require variables 
' to be defined in any way before being used. However, this is a very 
' useful practice to ensure that the memory space occupied is as optimized 
' as possible. In this specific case, this variable is used to iterate, 
' and therefore it is important that it is defined as a BYTE variable 
' so that the increments and comparisons are as fast as possible.

DIM i AS BYTE

'''---------------------------------------------------------------------------
''' RESOURCE LOADING
'''---------------------------------------------------------------------------

' With ugBASIC it is possible to read graphic resources directly from the 
' modern format (PNG, JPG, BMP, and so on), as the compiler takes care of 
' converting them to the target format. To do this, automatic algorithms 
' take care of many important phases, such as (for example) the construction 
' of an optimized palette. For this reason, in addition to indicating the 
' name of the file from which to read the graphic resource, it is possible 
' to suggest to ugBASIC how to treat the various images. Finally, in those 
' cases where targets can benefit from dedicated resources, it is possible 
' to create a folder with the name of the target to store the specific version 
' for that target, which will be loaded instead of the standard one.

' In this case, we are going to read the image used to draw the floor
' (i.e. an "empty" cell). Since it will be not modified, the "READONLY"
' keyword can be used. In this way and if possible, ugBASIC will not use 
' RAM to store the graphical data.

floorImage := LOAD IMAGE("images/floor.png") READONLY

' This is the player of the game.

playerImage := LOAD IMAGE("images/player.png") READONLY

' These two images represent, respectively, a level still to be solved 
' and the solved one. 

unlockedImage := LOAD IMAGE("images/unlocked.png") READONLY
lockedImage := LOAD IMAGE("images/locked.png") READONLY

' Image of the wall.

wallImage := LOAD IMAGE("images/wall.png")  READONLY

' Image of the arrow.

arrowImage := LOAD IMAGE("images/arrow.png") READONLY

' There two images are, respectively, the moving crate and the one
' that is well positioned on the final position.

crateImage := LOAD IMAGE("images/crate.png") READONLY
crateOnGoalImage := LOAD IMAGE("images/crate_in_place.png") READONLY

' This is the image used for the goal symbol.

goalImage := LOAD IMAGE("images/goal.png") READONLY

'''---------------------------------------------------------------------------
''' CONSTANT (POSITIONS) CALCULATION
'''---------------------------------------------------------------------------

' Once the graphic resources have been loaded, each of which may have specific
' dimensions related to the type of machine used, we can calculate a series of
' constants that we will use to draw objects on the screen. The advantage of 
' using constants is that they are calculated once and for all by the 
' compiler and they do not take up space on the executable, as they are used 
' directly in the generated code. Note that we not only define a constant, 
' but we require ugBASIC to verify that its value is greater than zero. 
' This check is essential because it is possible that the resolution of the 
' chosen computer is not sufficient to maintain all the graphic elements. 
' In this way, the compilation will be interrupted if the game cannot be 
' executed due to exceeding the graphic limits.

' This is the position from which we start drawing the arrow, and it is easy 
' to calculate: we start from the lower limit of the screen (SCREEN HEIGHT) 
' and subtract the height of the arrow. This way, we are sure that there 
' is enough space to draw it and that it will always take up minimal space.

POSITIVE CONST arrowTopY = SCREEN HEIGHT - IMAGE HEIGHT(arrowImage)

' At this point we calculate the vertical position in which we will draw 
' the state of the level, but in terms of characters. In fact, characters 
' are printed with a multiple of the height of the font used (FONT HEIGHT). 
' Therefore, once we calculate the starting point where to draw the arrow, 
' we move up the character height and then calculate that height in terms 
' of characters.

POSITIVE CONST levelsRow = ( arrowTopY - FONT HEIGHT ) / FONT HEIGHT

' The status, i.e. whether the level is still to be solved or not, is 
' drawn exactly above the level number. So we start from the state and 
' then move up the height of the symbol for the layer.

POSITIVE CONST levelsStatusY = ( levelsRow * FONT HEIGHT ) - FONT HEIGHT

' Now we can calculate the height and width of the wall. For reasons of 
' convenience, we have that each element (cell) of the game has the same 
' dimensions as the wall.

POSITIVE CONST wallImageWidth = IMAGE WIDTH( wallImage )
POSITIVE CONST wallImageHeight = IMAGE HEIGHT( wallImage )

' Now let's calculate the point from which to start drawing the game 
' plan. In practice, it involves calculating from which position you 
' will have to start drawing the table of 8x8 cells (each as large as 
' the size of the wall). The position is calculated as the central 
' position on the screen. So you take the width of the screen (SCREEN WIDTH),
' calculate half of it and then move to the left of the middle of the 
' game plan. This is done by taking the height of the screen (SCREEN HEIGHT),
' halving it and subtracting half the height of the playing surface. Since 
' we want the levels to be spaced a bit from the playing surface, we move 
' up one square.

POSITIVE CONST tilesStartX = ( SCREEN WIDTH / 2 ) - ( 4 * wallImageWidth )
POSITIVE CONST tilesStartY = ( ( SCREEN HEIGHT / 2 ) - ( 4 * wallImageHeight ) ) - wallImageHeight

' Let's quickly pre-calculate the coordinates of the perimeter walls.

POSITIVE CONST wallLeftX = tilesStartX
POSITIVE CONST wallTopY = tilesStartY
POSITIVE CONST wallBottomY = tilesStartY + 6*IMAGE HEIGHT(wallImage)
POSITIVE CONST wallRightX = wallLeftX + 7 * wallImageWidth

' Let's now calculate the height at which we need to draw the game title,
' as well as the animation elements. Indeed, each computer has its own 
' resolution, and the animation must be adapted. Moreover, avoid to
' runtime calculate by precalculating all elements.

POSITIVE CONST titleY0 = ( ROWS / 2 ) - 2
POSITIVE CONST titleY1 = titleY0+2
POSITIVE CONST titleY2 = IF ( titleY0+7 < ( ROWS - 1 ), titleY0+7, titleY0+6 ) 
POSITIVE CONST titleY3 = IF ( titleY0+9 < ROWS, titleY0+9, titleY0+7 )

POSITIVE CONST titleSX = ( ( SCREEN WIDTH - wallImageWidth ) / 2 ) - ( 2 * wallImageWidth )
POSITIVE CONST titleSY = ( titleY0 + 4 ) * FONT HEIGHT

' For convenience, let's calculate the positions of the various 
' elements that make up the game's introductory screen. The 
' advantage of doing it this way is to save code and memory 
' space by avoiding calculating these values ​​during execution.

POSITIVE CONST introPlayerX0 = titleSX
POSITIVE CONST introCrateX0 = titleSX + 2 * wallImageWidth
POSITIVE CONST introPlayerX1 = titleSX + wallImageWidth
POSITIVE CONST introPlayerX2 = titleSX + 2 * wallImageWidth
POSITIVE CONST introCrateX2 = titleSX + 3 * wallImageWidth
POSITIVE CONST introPlayerX3 = titleSX + 3 * wallImageWidth
POSITIVE CONST introGoalX0 = titleSX + 4 * wallImageWidth
POSITIVE CONST introCrateOnGoalX3 = titleSX + 4*wallImageWidth

' What is the displacement for each level?

POSITIVE CONST levelDisplacement = 3 * FONT WIDTH

' Finally, let's calculate how many levels can be represented on the screen, 
' all at once. And the same value divided by 2. And, finally, the maximum
' number of starting level on arrow drawing.

POSITIVE CONST maxLevelsOnScreen = ( COLUMNS / 3 ) - 1
POSITIVE CONST maxLevelsOnScreenHalved = maxLevelsOnScreen / 2
POSITIVE CONST maxLevelsOnScreenTop = 64 - maxLevelsOnScreen

'''---------------------------------------------------------------------------
''' OTHER (USEFUL) CONSTANTS
'''---------------------------------------------------------------------------

' Each cell type is represented by a specific value, which is a constant. 
' This constant coincides with the one used to initialize the game matrix.

CONST floor = 0
CONST wall = 1
CONST goal = 2
CONST crate = 3
CONST player = 4

' Each direction is described by a specific value, to which a value is 
' added to indicate when the FIRE button is pressed. This regardless of 
' whether you use the keyboard or the joystick

CONST none = 0
CONST up = 1
CONST down = 2
CONST left = 3
CONST right = 4
CONST fire = 5

' Here we calculate, based on the number of columns available, whether we 
' need to use the abbreviated or extended form of the authors' names. Note 
' that this type of check is carried out at compilation time: therefore, 
' in the end, the space actually occupied will only be given by one 
' of the two alternatives.

CONST authorShip = IF( COLUMNS > 30, "2022 Emanuele Feronato", "2022 E.Feronato" )
CONST authorShip2 = IF( COLUMNS > 30, "2024 Marco Spedaletti", "2024 M.Spedaletti" )

' Let's now calculate what indication to give the user, based on the 
' availability or otherwise of the joysticks.

CONST pressFire = IF( JOYCOUNT, "press FIRE", "press SPACE" )

'''---------------------------------------------------------------------------
''' DATA STRUCTURES
'''---------------------------------------------------------------------------

' This array actually contains the level being played at that moment. 
' It is, in fact, a (partial) copy of what was stored at the beginning. In 
' this case, since it is necessary to change the game plan at each level 
' change, the array is not defined as if it were read-only (therefore 
' it uses RAM).

DIM levelArray(8,8) AS BYTE 

' This vector contains the status of each level, i.e. whether it has been 
' solved or not. If it has been resolved, the value will be TRUE otherwise 
' it will be FALSE. The fact that we are working with a binary value allows 
' us to take advantage of the BIT data type. This type of data allows you 
' to optimize the space occupied: therefore the 64 levels will occupy 64 bits
' equal to 8 bytes (instead of 64 bytes).

DIM solvedLevels(64) AS BIT WITH 0 

' This variable maintains the current game level, which starts with 
' the first level (0 based).

DIM level AS BYTE = 0

' These variables contain the positions (coordinates) relative to the 
' cell you are drawing.

DIM posX AS BYTE
DIM posY AS BYTE

' This variable contains the index of the array over the 
' entire game map.

DIM index

' These variables maintain the player's position.

DIM playerX AS BYTE
DIM playerY AS BYTE

' These variables maintain the player's subsequent 
' position if he wanted to move.

DIM destinationX AS BYTE
DIM destinationY AS BYTE 

' These variables maintain the crate's subsequent 
' position if he wanted to move.

DIM crateDestinationX AS BYTE
DIM crateDestinationY AS BYTE

' This variabile stores the first level showed 
' on the levels status.

DIM start AS BYTE

' This variable was introduced to represent which operating mode the
' videogame is in. Taking into account that not all computers have a 
' joystick and a keyboard, we chose to adopt an interface that can 
' also be used with just a joystick. To be able to do this, the game 
' has two modes. The actual game mode (FALSE) in which the player can 
' move the character vertically and horizontally, and move the crates. 
' The layer choice mode (TRUE) that allows you to move forward (right)
' and backward (left) between layers or repeat the layer (up). 
' To move from one level to another you will use the FIRE button. Also 
' in this case, since we only have two values, it is appropriate to 
' use the BIT data type.

DIM menuMode AS BIT

' This variable allows you to store the direction read by the 
' peripheral, be it a joystick or the keyboard.

DIM direction AS BYTE

'''---------------------------------------------------------------------------
''' PROCEDURES
'''---------------------------------------------------------------------------

' This procedure reads the direction in which the player wants to 
' move the character or if he wants to make a change on the levels. 
' Reading, in this case, takes place using the first available joystick.
' This is a conditionally compiled procedure, with the help of the 
' "ON" statement. This instruction allows you to indicate whether 
' a procedure or the related call is to be compiled for the 
' indicated target. As a rule, in fact, the parameter of the "ON"
' command is a target or a list of targets, separated by a comma. 
' However, other conditions are also present. In this case, the 
' procedure will be compiled (and therefore the code will be 
' generated) only if the target has at least one joystick.

PROCEDURE readDirection ON JOYSTICK AVAILABLE

	' To save space, we share the variable that will maintain 
	' the indicated direction between the main program and the 
	' procedure, and thus also avoid having to copy it as a 
	' return value.
	
	SHARED direction

	' We start without direction.
	
	direction = none
	
	' joystick up?
	IF JUP(0) THEN
	
		' wait for joystick stick returns
		' to the original position.
		WHILE JUP(0):WEND
		
		' Direction read is UP
		direction = up
		
	' joystick down?
	ELSE IF JDOWN(0) THEN
	
		' wait for joystick stick returns
		' to the original position.
		WHILE JDOWN(0):WEND
		
		' Direction read is DOWN
		direction = down

	' joystick left?
	ELSE IF JLEFT(0) THEN

		' wait for joystick stick returns
		' to the original position.
		WHILE JLEFT(0):WEND
		
		' Direction read is LEFT
		direction = left
		
	' joystick right?
	ELSE IF JRIGHT(0) THEN

		' wait for joystick stick returns
		' to the original position.	
		WHILE JRIGHT(0):WEND
		
		' Direction read is RIGHT
		direction = right
		
	' fire button?
	ELSE IF JFIRE(0) THEN

		' wait for joystick stick returns
		' to the original position.
		WHILE JFIRE(0):WEND
		
		' Direction read is FIRE
		direction = fire
		
	ENDIF
 	
END PROC

' This procedure reads the direction in which the player wants to 
' move the character or if he wants to make a change on the levels. 
' Reading, in this case, takes place using the keyboard.
' This is a conditionally compiled procedure, see above.

PROCEDURE readDirection ON JOYSTICK NOT AVAILABLE

	' To save space, we share the variable that will maintain 
	' the indicated direction between the main program and the 
	' procedure, and thus also avoid having to copy it as a 
	' return value.
	
	SHARED direction

	' We start without direction.
	
	direction = none
	
	' key press up?
	IF KEY STATE(KEY UP) THEN
	
		' wait for key release
		WHILE KEY STATE(KEY UP):WEND
		
		' Direction read is UP
		direction = up

	' key press down?
	ELSE IF KEY STATE(KEY DOWN) THEN

		' wait for key release
		WHILE KEY STATE(KEY DOWN):WEND
		
		' Direction read is DOWN
		direction = down
		
	' key press left?
	ELSE IF KEY STATE(KEY LEFT) THEN

		' wait for key release
		WHILE KEY STATE(KEY LEFT):WEND
		
		' Direction read is LEFT
		direction = left
		
	' key press right?
	ELSE IF KEY STATE(KEY RIGHT) THEN

		' wait for key release
		WHILE KEY STATE(KEY RIGHT):WEND
		
		' Direction read is RIGHT
		direction = right

	' key press space?
	ELSE IF KEY STATE(KEY SPACE) THEN

		' wait for key release
		WHILE KEY STATE(KEY SPACE):WEND
		
		' Direction read is FIRE
		direction = fire
		
	ENDIF
 	
END PROC

' This procedure shows the line with the commands that can be given 
' to change the level, or to repeat it.

PROCEDURE showChangeLevelControls

	LOCATE 0, 0 : PRINT "<-"	
	LOCATE , 0 : CENTER "^ retry ^"	
	LOCATE COLUMNS - 3, 0 : PRINT "->" 
	
END PROC

'''---------------------------------------------------------------------------
''' MAIN PROGRAM
'''---------------------------------------------------------------------------

' With this instruction we clear the screen, using (if possible) the color 
' black. Remembering that ugBASIC is an isomorphic language, it is possible 
' that the color indication is ignored, or a similar one is chosen.

CLS BLACK

' First, let's draw the elements on the screen that make up the game's home 
' screen. These items are, in sequence: the player character, a crate, and 
' the goal. This arrangement represents the first frame of the animation
' that we will show as soon as the user presses a button (or the FIRE button 
' on the joystick).

' INTRO ANIMATION - FRAME 0

PUT IMAGE playerImage AT introPlayerX0, titleSY
PUT IMAGE crateImage AT introCrateX0, titleSY
PUT IMAGE goalImage AT introGoalX0, titleSY

' Now we use the WHITE color to print the info about
' the game name and authors.

PEN WHITE

' Let's now print the title of the game, the procedure and the name 
' of the author. By using the CENTER command it is possible to 
' print a text in the center of the screen, at the position 
' indicated by the LOCATE command.

LOCATE , titleY0 : CENTER "SOKO64+"
LOCATE , titleY1  : CENTER pressFire
LOCATE , titleY2 : CENTER authorShip
LOCATE , titleY3 : CENTER authorShip2

' We are waiting for the FIRE button on the joystick or any key 
' on the keyboard to be pressed.

WAIT KEY OR FIRE RELEASE

' INTRO ANIMATION - FRAME 1

PUT IMAGE floorImage AT introPlayerX0, titleSY
PUT IMAGE playerImage AT introPlayerX1, titleSY

' Wait for 100 milliseconds for next frame

WAIT 100 MILLISECONDS

' INTRO ANIMATION - FRAME 2

PUT IMAGE floorImage AT introPlayerX1, titleSY
PUT IMAGE playerImage AT introPlayerX2, titleSY
PUT IMAGE crateImage AT introCrateX2, titleSY

' Wait for 100 milliseconds for next frame

WAIT 100 MILLISECONDS

' INTRO ANIMATION - FRAME 3

PUT IMAGE floorImage AT introPlayerX2, titleSY
PUT IMAGE playerImage AT introPlayerX3, titleSY
PUT IMAGE crateOnGoalImage AT introCrateOnGoalX3, titleSY

' Wait for 1 second to continue

WAIT 1000 MILLISECONDS

' Starting from this position, the routine that deals with drawing 
' the level in which the player finds himself/herself. In this case, 
' the original author had opted to use unconditional jump labels. 
' As an alternative to this approach, a procedure could also 
' have been used.

playLevel: 

	' Clear the screen at the beginning.
	
	CLS

	' Here we are concerned with designing a truly functional arrow. 
	' In other words, the arrow should be able to move freely 
	' between levels only if we are viewing the first few levels. 
	' After this limit, we keep the arrow still until we reach
	' the end of the levels.
	
	IF level < maxLevelsOnScreen THEN
	
		' The first level is the level 1.
	
		start = 1
		
	ELSE
	
		' The first level must be calculated.
		
		start = level - maxLevelsOnScreenHalved - 1
		
		' We must manage the maximum level.
		
		IF start > maxLevelsOnScreenTop THEN
			start = maxLevelsOnScreenTop
		ENDIF
		
	ENDIF

	' First, let's draw the levels. Each level is drawn with the number
	' and status (solved / unsolved).
	
	FOR i = 0 TO maxLevelsOnScreen 

		' This code is used to print a number with two digits, even 
		' when the level number consists of a single decimal digit.
		
		IF start + i < 10 THEN
			LOCATE i * 3 + 1, levelsRow : PRINT "0";
			LOCATE i * 3 + 2, levelsRow : PRINT (start + i);
		ELSE
			' else just print level number
			LOCATE i * 3 + 1, levelsRow : PRINT (start + i);
		ENDIF
		
		
		' Now we update the state of the level, depending on whether 
		' it is solved or not, using the relevant image.
		
		IF solvedLevels(start + i - 1) = TRUE THEN
			PUT IMAGE unlockedImage AT FONT WIDTH + levelDisplacement * i, levelsStatusY
		ELSE
			PUT IMAGE lockedImage AT FONT WIDTH + levelDisplacement * i, levelsStatusY
		ENDIF
				
	NEXT

	' We draw the arrow in the appropriate position.
	
	PUT IMAGE arrowImage AT FONT WIDTH + (level - start + 1) * levelDisplacement, arrowTopY
	
	' Let's initialize the position from which to start drawing the game plan.
	
	posX = tilesStartX
	posY = tilesStartY
	
	' Let's position ourselves at the beginning of the array that contains 
	' the data for the level in progress. Since, as we explained at the 
	' beginning, there are 6x6 cells defined for each level, each level 
	' occupies 36 cells.
	
	index = 36 * level
	
	' This loop takes care of drawing the top and bottom part
	' of the game plan, one element at a time. Since there are 
	' 8 columns in the game plan, we will repeat the loop eight
	' times (0 to 7).
	
	FOR i = 0 TO 7
	
		' First, let's fill (and draw) the top row of cells.
		
		levelArray(0, i) = wall
		PUT IMAGE wallImage AT posX, posY
		
		' Then, let's fill (and draw) the bottom row of cells.
		
		levelArray(7, i) = wall
		PUT IMAGE wallImage AT posX, posY + 7 * wallImageHeight
		
		 ' Move ahead on the next cell
		 
		ADD posX, wallImageWidth
		
	NEXT i

	' Move to the next row of cells
	
	ADD posY, wallImageHeight
	
	' This loop takes care of drawing the various rows of
	' the play ground.
	
	FOR i = 1 TO 6

		' First, let's fill (and draw) the left column of cells.
		
		levelArray(i, 0) = wall
		PUT IMAGE wallImage AT wallLeftX, posY 
		
		' Then, let's fill (and draw) the right column of cells.
		
		levelArray(i, 7) = wall
		PUT IMAGE wallImage AT wallRightX, posY
		
		' Now, we are going to draw the play ground of this
		' row of cells. The starting position is on the right
		' of the left column.
		
		posX = tilesStartX + wallImageWidth
		
		' This loop takes care of drawing the cells for the reference row.
		
		FOR j = 1 TO 6
		
			' Let's find out what type of cell we need to draw 
			
			value = levels(index)

			' By default, we assume it's a floor.
			
			levelArray(i, j) = floor
			
			' If the value we get from the map is a wall, 
			' we need to draw it.
			
			IF value = wall THEN
			
				' Fill and draw a wall
				
				levelArray(i, j) = wall
				PUT IMAGE wallImage AT posX, posY
				
			ENDIF
			
			' If the value we get from the map is the player,
			' we need to draw it and to save the initial
			' player position.
			
			IF value = player THEN
			
				levelArray(i, j) = player
				PUT IMAGE playerImage AT posX, posY
				
				playerX = j
				playerY = i
				
			ENDIF
			
			' If the value we get from the map is the player
			' over the goal, we need to draw it and to save 
			' the player position.
			
			IF value = player + goal THEN
				levelArray(i, j) = player + goal
				PUT IMAGE playerImage AT posX, posY
				playerX = j
				playerY = i
			ENDIF
			
			' If the value we get from the map is the crate,
			' we need to draw it.
			
			IF value = crate THEN
				levelArray(i, j) = crate
				PUT IMAGE crateImage AT posX, posY
			ENDIF
			
			' If the value we get from the map is the goal
			' we need to draw it.
			
			IF value = goal THEN
				levelArray(i, j) = goal
				PUT IMAGE goalImage AT posX, posY
			ENDIF	
			
			' If the value we get from the map is the crate
			' over the goal, we need to draw it.
			
			IF value = crate + goal THEN
				levelArray(i, j) = crate + goal
				PUT IMAGE crateOnGoalImage AT posX, posY
			ENDIF	
			
			' Move to the next cell (on this row)
			
			ADD posX, wallImageWidth
			
			' Move on the next cell (on the map)
			
			INC index
			
		NEXT j
		
		' Move to the next row
		
		ADD posY, wallImageHeight
		
	NEXT i

' Starting from this position, the original author has inserted 
' a routine that takes care of receiving input from the player. 
' A series of instructions have been added to this routine, 
' aimed at changing the operating mode.

playerInput:  

	' If the game mode is the classic one, where the player 
	' moves the character (menuMode = FALSE), then we must 
	' delete the instructions that suggest how to change 
	' the levels.

	IF menuMode = FALSE THEN
		HOME: CLINE
	ELSE
		showChangeLevelControls[]
	ENDIF

	' This loop waits for an action from the user.
	
	DO
	
		' With this statement we are calling the "readDirection" 
		' procedure. Note that there are two procedures defined 
		' with this name in the program: however, ugBASIC will 
		' only compile one of them, depending on whether a 
		' joystick is present or not.
	
		readDirection[]
		
		' If we are in traditional game mode (menuMode = FALSE) then...
		
		IF menuMode = FALSE THEN
		
			' If asked to move left, we move both the player 
			' and any crate left.
			
			IF direction = left THEN
			
				' Move character left.
				
				destinationX = playerX - 1
				destinationY = playerY

				' Move crate left.

				crateDestinationX = destinationX - 1
				crateDestinationY = destinationY
				
				' Update the player's position.
				
		  		GOTO movePlayer
		  		
			ENDIF
			
			' If asked to move right, we move both the player 
			' and any crate right.
			
			IF direction = right THEN
			
				' Move character right.
				
				destinationX = playerX + 1
				destinationY = playerY

				' Move crate right.
				
				crateDestinationX = destinationX + 1
				crateDestinationY = destinationY
				
				' Update the player's position.
				
				GOTO movePlayer
				
			ENDIF
			
			' If asked to move up, we move both the player 
			' and any crate up.
			
			IF direction = up THEN
			
				' Move character up.
				
				destinationX = playerX 
				destinationY = playerY - 1

				' Move create up.
				
				crateDestinationX = destinationX 
				crateDestinationY = destinationY - 1
				
				' Update the player's position.
				
				GOTO movePlayer
				
			ENDIF
			
			' If asked to move down, we move both the player 
			' and any crate down.
			
			IF direction = down THEN
			
				' Move character down.
				
				destinationX = playerX 
				destinationY = playerY + 1

				' Move crate down.

				crateDestinationX = destinationX
				crateDestinationY = destinationY + 1
				
				' go to movePlayer routine
				
				GOTO movePlayer
				
			ENDIF

			' If the fire button has been pressed,
			' we have to change the menu mode.
			
			IF direction = fire THEN
				menuMode = TRUE
				GOTO playerInput
			ENDIF
			
		ELSE
		
			' If asked to try a previous level, and there are
			' enough level to decrease, we move to the previous 
			' level (and update the play field).
			
			IF ( direction = left ) AND (level > 0) THEN	
				DEC level
				GOTO playLevel
			ENDIF
			
			' If asked to try the next level, and there are
			' enough level left to increase, we move to the 
			' next level (and update the play field).
			
			IF ( direction = right ) AND (level < 63) THEN	
				INC level
				GOTO playLevel
			ENDIF
	
			' If asked to retry this level, we will update
			' the play field.
			
			IF ( direction = up ) THEN
				GOTO playLevel
			ENDIF

			' If the fire button has been pressed,
			' we have to change the menu mode.
			
			IF ( direction = fire ) THEN
				menuMode = FALSE
				GOTO playerInput
			ENDIF
		
		ENDIF
		
	LOOP
	
' Starting from this position, the original author has inserted a routine 
' that deals with applying the player's movement, where the conditions 
' obviously exist.

movePlayer :

	' If the target position on the game is free 
	' or there is an goal symbol...
	
	IF (levelArray(destinationY, destinationX) = goal) OR (levelArray(destinationY, destinationX) = floor) THEN

		' Was the previous position occupied by the player?
		
		IF levelArray(playerY, playerX) = player THEN
			PUT IMAGE floorImage AT tilesStartX + playerX*wallImageWidth, tilesStartY + playerY* wallImageHeight
		ELSE
			PUT IMAGE goalImage AT tilesStartX + playerX*wallImageWidth, tilesStartY + playerY*wallImageHeight
		ENDIF	
		
		' We can now remove the player from the copied array.
		
		ADD levelArray(playerY, playerX), - player
		
		' We can now update the player position.
		
		playerX = destinationX
		playerY = destinationY
		
		' And, then, add again the player into the copied array.
		
		ADD levelArray(destinationY, destinationX), player
		
		' Let's draw the player on the correct position.
		
    	PUT IMAGE playerImage AT tilesStartX + playerX*wallImageWidth, tilesStartY + playerY*wallImageHeight 
    	
    	' Wait 100 milliseconds to emulate movement.
    	
    	WAIT 100 MILLISECONDS
    	
    	' Let's repeat the input management.
    	
    	GOTO playerInput
    	
    ENDIF

	' If the target position on the game is a crate or a positioned crate...

    IF (levelArray(destinationY, destinationX) = crate) OR (levelArray(destinationY, destinationX) = crate + goal) THEN
    
    	' if crate destination is a goal or a floor (walkable tile)...
    	
		IF (levelArray(crateDestinationY, crateDestinationX) = goal) OR (levelArray(crateDestinationY, crateDestinationX) = floor) THEN
			
			' Check if the player is alone on that cell, so that
			' we can draw the player image. Otherwise, we can
			' draw the image of the goal.
			
			' Was the previous position occupied by the player?
			
			IF levelArray(playerY, playerX) = player THEN
				PUT IMAGE floorImage AT tilesStartX + playerX*wallImageWidth, tilesStartY + playerY*wallImageHeight 
			ELSE
				PUT IMAGE goalImage AT tilesStartX + playerX*wallImageWidth, tilesStartY + playerY*wallImageHeight
			ENDIF
			
			' We can now remove the player from the copied array.
					
			ADD levelArray(playerY, playerX), - player
			
			' We can now update the player position.
			
			playerX = destinationX
			playerY = destinationY
			
			' And, then, add again the player into the copied array.
			
			ADD levelArray(destinationY, destinationX), player
			
			' We can now remove the crate from the copied array.
			
			ADD levelArray(destinationY, destinationX), - crate
			
			' We can now add the crate to the copied array.
			
			ADD levelArray(crateDestinationY, crateDestinationX), crate
			
			' And, then, we can draw the player
			
	    	PUT IMAGE playerImage AT playerX * wallImageWidth + tilesStartX, playerY * wallImageHeight + tilesStartY
	    	
	    	' The color of crate is different if the crate is positioned over a goal.
	    	
	    	IF levelArray(crateDestinationY, crateDestinationX) = crate + goal THEN
	    		PUT IMAGE crateOnGoalImage AT crateDestinationX * wallImageWidth + tilesStartX, crateDestinationY * wallImageHeight + tilesStartY
	    	ELSE
	    		PUT IMAGE crateImage AT crateDestinationX * wallImageWidth + tilesStartX, crateDestinationY * wallImageHeight + tilesStartY
	    	ENDIF
	    	
	    	' This loop checks whether the game level being played is finished, 
	    	' i.e. whether there are no more goals to cover with a crate.
	    	
	    	FOR i = 0 TO 7
	    	
    	 		FOR j = 0 TO 7
    	 		
    	 			' If we find at least one element still to be covered,
    	 			' wait just a moment and start again waiting for input.
    	 			
    	 			IF (levelArray(i, j) = goal) OR (levelArray(i, j) = player + goal) THEN
    	 				WAIT 100 MILLISECONDS
	    				GOTO playerInput		
    	 			ENDIF
    	 			
    	 		NEXT j
    	 		
    	 	NEXT i
    	 	
    	 	' If we did not find any goal without a crate on it, 
    	 	' go to levelCompleted routine
    	 	
    	 	GOTO levelCompleted	
    	 	
		ENDIF
		
	ENDIF
	
	' Start again waiting for input.
	
	GOTO playerInput

' Starting from this position, the original author inserted the routine 
' to perform when a level is complete. In that case, we need to enable 
' the level switching operation mode.

levelCompleted:

	' We print the message on the screen, to indicate 
	' that the level is completed.
	
	LOCATE , 1 : CENTER "SOLVED!" 
	
	' We mark the level as solved.
	
	solvedLevels(level) = TRUE

	' Show the controls.
	
	showChangeLevelControls[]
	
	' This loop deals with waiting for the player's next move.
	
	DO
	
		' Read the action.
		
		readDirection[]
	
		' UP ? Repeat this level.
		
		IF direction = up THEN
			GOTO playLevel
		ENDIF
	
		' LEFT ? Move to the previous level.
		
		IF ( direction = left ) AND (level > 0) THEN	
			DEC level
			GOTO playLevel
		ENDIF
		
		' RIGHT ? Move to the next level.
		
		IF ( direction = right ) AND (level < 63) THEN	
			INC level
			GOTO playLevel
		ENDIF
		
	LOOP



