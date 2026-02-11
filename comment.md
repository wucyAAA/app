• - lib/screens/comments_screen.dart:124-158 启动新搜索/筛选时复用 _loadData，但这里没有像 _onRefresh 一样调用
    _refreshController.resetNoData()（对比 lib/screens/comments_screen.dart:190-194）。如果用户在旧数据里已经触发过       
    loadNoData()，SmartRefresher 会维持“没有更多”状态，新的搜索结果即使还有下一页也无法上拉加载，必须手动下拉一次才会恢   
    复。建议在每次重新拉取第一页前先 resetNoData()。
  - lib/screens/comments_screen.dart:37-41, 274-297, 1471-1478 维护了 selectedGroups 并在筛选回调中传递，但筛选面板没有任 
    何群组选项，API 请求也未使用该参数（CommentApi.getList 调用处仅传 time/tags/keyword）。当前群组筛选形同虚设，若业务需 
    要该维度，需补齐 UI 与请求参数。