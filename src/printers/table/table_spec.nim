
const
    TABLE_VBORDER : char = '|'
    TABLE_HBORDER : char = '-'
    TABLE_CBORDER : char = '+'
    TABLE_FILL    : char = 'X'

    TABLE_BORDER_SIZE* : int = 1

type
    TableSpec* = object
        ## Table (grid) specification

        cellWidth*  : int ## Width of a table cell
        cellHeight* : int ## Height of a table cell

        marginX*    : int ## Horizontal margin around each table cell
        marginY*    : int ## Vertical   margin around each table cell

        borderV*    : char ## Vertical separator between cells
        borderH*    : char ## Horizontal separator between cells
        borderC*    : char ## Cell corner

        fillChar*   : char ## Character to fill empty cells with

        nRows*      : int  ## Number of table rows
        nCols*      : int  ## Number of table columns

    TableCell*  = seq[string]
    TableCells* = seq[seq[TableCell]]

proc initTableSpec*(
    cellWidth : int, cellHeight : int, marginX : int, marginY : int,
    fillChar  : char = TABLE_FILL
) : TableSpec =

    return TableSpec(
        cellWidth  : cellWidth,
        cellHeight : cellHeight,
        marginX    : marginX,
        marginY    : marginY,
        borderV    : TABLE_VBORDER,
        borderH    : TABLE_HBORDER,
        borderC    : TABLE_CBORDER,
        fillChar   : fillChar,
        nRows      : 0,
        nCols      : 0,
    )

