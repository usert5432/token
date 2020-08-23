import ./color_map

type
    Config* = object
        cfgFile*  : string
        rootDir*  : string
        pageSize* : int
        cmap*     : ColorMap

