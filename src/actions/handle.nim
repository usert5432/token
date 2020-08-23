import action_add
import action_del
import action_export
import action_graph
import action_info
import action_list
import action_table

import ../args/args_obj
import ../config/config_obj

proc handleAction*(args : Args, config : Config) =

    if args == nil:
        raise newException(ValueError, "No action selected")

    case args.kind
    of ArgsKind.Add:
        handleActionAdd(args, config)

    of ArgsKind.Del:
        handleActionDel(args, config)

    of ArgsKind.Export:
        handleActionExport(args, config)

    of ArgsKind.Graph:
        handleActionGraph(args, config)

    of ArgsKind.Info:
        handleActionInfo(args, config)

    of ArgsKind.Table:
        handleActionTable(args, config)

    of ArgsKind.List:
        handleActionList(args, config)

