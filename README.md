| | | | |
|-|-|-|-|
|ListenReadSpeaker webReader: ListenOpen/close toolbarFocus| | | |
| | | | |
|Haskell Project| | | |
| | | | |
|Description| | | |
| | | | |
|This program reads a maze and finds a path through the maze. Specifically, the maze has <span style="display: inline-block; position: relative; width: 1.393em; height: 0px; font-size: 138%;"><span style="position: absolute; clip: rect(3.461em, 1001.36em, 5.316em, -999.998em); top: -3.993em; left: 0em;"><span class="mrow" id="MathJax-Span-2"><span style="display: inline-block; position: relative; width: 1.393em; height: 0px;"><span style="position: absolute; clip: rect(3.461em, 1000.72em, 4.104em, -999.998em); top: -3.993em; left: 0em;"><span class="mi" id="MathJax-Span-3" style="font-family: STIXGeneral-Italic;">m×nm×n cells. It starts in the top-left cell and find a path to the bottom-right cell:| | | |
| | | | |
|The maze will have no cycles. Graph-theoretically.| | | |
| | | | |
|Input Format| | | |
| | | | |
|The input file is a binary file:| | | |
| | | | |
|The first four bytes are the height of the maze in little-endian format. In other words, the lowest byte is stored first. The number 517, for example would be represented as the byte sequence 05,02,00,00 because 517 == 0x00000205.| | | |
| | | | |
|The next four bytes are the width of the maze in little-endian format.| | | |
| | | | |
|The remaining bytes encode the walls between cells:| | | |
|The outside walls surrounding the maze are not represented explicitly.| | | |
|The remaining walls are stored by storing for every cell whether there is a wall to its right or below it. This requires two bits per cell.| | | |
|We view the bits in the input as storing the cells of the grid in row-major order, that is, first the cells on the top row, ordered left to right, then the second row, ordered left to right, and so on. The first byte encodes the first four cells in this sequence, the second byte encodes the next four cells in this sequence, and so on. Within a byte, the lowest two bits store the walls for the first cell in the corresponding subsequence of four cells, the next two bits store the walls for the next cell, and so on. The highest two bits store the valls of the last cell in the four-cell sequence. As an example, the lowest two bits of the first input byte store the walls of the top-left grid cell. The next two bits store the walls of the second cell on the first row. The highest two bits of the first byte store the walls of the fourth cell on the first row.| | | |
|The two bits xy encoding the walls for a cell are interpreted as follows:| | | |
|x = 1: There’s a wall below this cell. x = 0: There is no wall below this cell.| | | |
|y = 1: There’s a wall to the right of this cell. y = 0: There is no wall to the right of this cell.| | | |
|As an illustration, here is the byte sequence encoding the 5x5 maze above (numbers are shown in hexadecimal representation):| | | |
|05 00 00 00 05 00 00 0030 1C 4B C9 86 00 00Let’s pick this apart, using the format (row,column) to refer to the grid cells, numbering both rows and columns starting from 0.| | | |
|The first four bytes 05 00 00 00 store the number 0x00000005 = 5 in little-endian format. That’s the height of the maze.| | | |
|The next four bytes 05 00 00 00 store the number 0x00000005 = 5 in little-endian format. That’s the width of the maze.| | | |
|The byte 30 is 00110000 in binary. Thus, the cells (0,0) and (0,1) have no walls to their right or below them, cell (0,2) has walls to its right and below it, and cell (0,3) has no walls to its right or below it.| | | |
|The byte 1C is 00011100 in binary. Thus, the cell (0,4) has no walls to its right or below it. (Remember, the outside walls are not stored explicitly.) The cell (1,0) has walls to its right and below it. The cell (1,1) is represented by the bit pair 01, so it has a wall to its right but none below it. The cell (1,2) has no walls to its right or below it.| | | |
|The byte 4B is 01001011 in binary. Thus, the cell (1,3) has walls to its right and below it. The cell (1,4) is represented by the bit pair 10, so it has a wall below it but not to its right. (Actually, it does, but that’s an outside wall, which is not stored.) The cell (2,0) has no walls to its right or below it. The cell (2,1) is represented by the bit pair 01 and thus has a wall to its right but not below it.| | | |
|The remaining bytes are to be interpreted in the same fashion.| | | |
|Output Format| | | |