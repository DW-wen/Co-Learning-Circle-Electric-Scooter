// 駐警隊監控台介面文字 —— 繁體中文（台灣）
//
// All dashboard wording lives here so it can be reviewed in one place.
// Enum -> label mapping is in labels.dart.

class S {
  S._();

  // ------------------------------------------------------------- app / nav
  static const String appTitle = '駐警隊充電站監控台';
  static const String railTitle = '駐警隊監控台';
  static const String navStations = '充電站總覽';
  static const String navLogs = '使用紀錄';
  static const String navPoints = '記點查詢';
  static const String navBans = '停權名單';
  static const String navIncidents = '異常與回報';

  /// PLACEHOLDER for the signed-in officer (no login yet).
  static const String currentOfficer = '值班員 #101';

  static const String cancel = '取消';
  static const String none = '—';
  static const String all = '全部';
  static const String filter = '篩選：';
  static const String moreActions = '更多操作';

  static String spotName(String label) => '$label 號充電位';
  static String fullSpot(String zone, String label) => '$zone · $label 號充電位';
  static String pts(int n) => '$n 點';
  static String days(int n) => '$n 天';
  static String daysHours(int d, int h) => '$d 天 $h 小時';

  // ----------------------------------------------------------- 狀態標籤
  static const String statusNotCharging = '未充電';
  static const String statusCharging = '充電中';
  static const String statusOccupied = '佔用';
  static const String statusOffline = '維修中';

  // ---------------------------------------------------------- 充電站總覽
  static const String stationsTitle = '充電站總覽';
  static const String stationsSubtitle = '依區域顯示即時狀態 · 警示依下方門檻計算';
  static const String kpiSpots = '充電位';
  static const String kpiCharging = '充電中';
  static const String kpiOccupied = '佔用（停放未充電）';
  static const String kpiFree = '未充電（空位）';
  static const String kpiOffline = '維修中';
  static const String kpiAlerts = '警示：超時／將超時';
  static const String alertsOnly = '僅顯示警示';
  static const String noMatch = '沒有符合篩選條件的充電位';
  static String spotCount(int n) => '$n 個充電位';

  static const String thresholdsTitle = '警示門檻（可調整）';
  static const String chargingLimit = '充電上限';
  static const String occupiedLimit = '佔用（未充電）上限';
  static const String placeholderRule = '暫定值 · 規則待定';
  static String nearingNote(int charging, int occupied) =>
      '「將超時」＝距上限 $charging 分鐘內（充電）／$occupied 分鐘內（佔用）';
  static String minutes(int n) => '$n 分鐘';
  static const String decrease = '減少';
  static const String increase = '增加';

  static const String noUser = '— 無使用者 —';
  static const String unscanned = '未掃碼佔用（無使用紀錄）';
  static String chargingFor(String d, String since) => '已充電 $d（$since 起）';
  static String parkedFor(String d, String since) => '已停放 $d（$since 起）';
  static String offlineSince(String since) => '維修中（$since 起）';
  static String alertOverCharging(String d) => '充電超時 $d';
  static String alertOverOccupied(String d) => '佔用超時 $d';
  static String alertNearing(String d) => '距上限剩 $d';

  static const String menuRecordPoints = '記點';
  static const String menuSetOffline = '設為維修中';
  static const String menuSetOnline = '恢復服務';
  static String setOfflineDone(String id) => '$id 已設為維修中';
  static String setOnlineDone(String id) => '$id 已恢復服務';

  // ------------------------------------------------------------ 使用紀錄
  static const String logsTitle = '使用紀錄';
  static const String logsSubtitle = '稽核軌跡 · 誰在何時使用了哪個充電位';
  static const String searchLogs = '搜尋學號、姓名或充電位';
  static const String zone = '區域';
  static const String allZones = '全部區域';
  static const String spot = '充電位';
  static const String allSpots = '全部充電位';
  static String modeRecent(int months) => '近 $months 個月';
  static const String modeDate = '指定日期';
  static const String dateLabel = '日期（西元）';
  static String retentionNote(int months, String from) =>
      '可查詢近 $months 個月內的紀錄（$from 起）· 藍點表示當日有紀錄';
  static String dayRecords(String date, int n) => '$date · 共 $n 筆';
  static String records(int n) => '共 $n 筆';
  static const String noRecords = '沒有符合條件的紀錄';
  static const String colSpot = '充電位';
  static const String colZone = '區域';
  static const String colStudentId = '學號';
  static const String colName = '姓名';
  static const String colStart = '開始';
  static const String colEnd = '結束';
  static const String colDuration = '時長';
  static const String inProgress = '使用中';

  // ------------------------------------------------------------ 記點查詢
  static const String pointsTitle = '記點查詢';
  static const String pointsSubtitle = '學生累計違規點數與記點時間';
  static const String searchStudent = '學號或姓名';
  static const String noStudents = '查無學生';
  static const String selectStudent = '請選擇學生以查看記點紀錄';
  static const String serviceAllowed = '可使用服務';
  static String bannedUntil(String t) => '停權至 $t';
  static const String kpiTotalPoints = '累計點數';
  static const String kpiRecordCount = '記點筆數';
  static const String kpiLastRecorded = '最近記點';
  static const String rulesTbd = '點數到期與停權門檻規則待定 —— 目前為全部紀錄加總。';
  static const String noPointRecords = '尚無記點紀錄';
  static const String colRecordedAt = '記錄時間';
  static const String colPoints = '點數';
  static const String colReason = '原因';
  static const String colLocation = '地點';
  static const String colRecordedBy = '記錄者';
  static const String recordPoints = '記點';
  static const String issueBan = '停權';
  static String pointsRecorded(String name, int n) => '已為 $name 記 $n 點';
  static String banIssued(String name, int days) => '已將 $name 停權 $days 天';

  // ------------------------------------------------------------ 停權名單
  static const String bansTitle = '停權名單';
  static const String bansSubtitle = '目前停權中的學生（已到期者不顯示）';
  static String suspendedCount(int n) => '目前共 $n 位學生停權中';
  static const String noBans = '目前沒有停權中的學生';
  static const String colFrom = '停權開始';
  static const String colUntil = '停權結束';
  static const String colLength = '停權期間';
  static const String colRemaining = '剩餘';
  static const String colActions = '操作';
  static const String liftBan = '解除停權';
  static String liftBanTitle(String name) => '解除 $name 的停權？';
  static const String liftBanBody = '解除後該學生可立即恢復使用充電服務。';
  static String banLifted(String name) => '已解除 $name 的停權';

  // -------------------------------------------------------------- 對話框
  static String recordPointsTitle(String name) => '為 $name 記點';
  static const String reason = '違規原因';
  static const String points = '點數';
  static const String location = '地點';
  static const List<String> violationReasons = [
    '充電超過 4 小時上限',
    '充電完成後未移車',
    '未掃碼即佔用充電位',
    '未登記車輛佔用充電位',
    '其他',
  ];
  static const String confirmRecord = '確認記點';
  static String banTitle(String name) => '將 $name 停權';
  static const String banLength = '停權期間';
  static const List<int> banDayOptions = [3, 7, 14, 30];
  static const String banReason = '停權原因';
  static const String banReasonDefault = '駐警隊人工停權';
  static const String confirmBan = '確認停權';

  // ------------------------------------------------------------ 異常與回報
  static const String incidentsTitle = '異常與回報';
  static const String incidentsSubtitle = '學生回報、系統偵測與巡邏通報的充電位異常';
  static const String kpiOpen = '未處理';
  static const String kpiInProgress = '處理中';
  static const String kpiResolvedToday = '今日已解決';
  static const String kpiOfflineSpots = '維修中充電位';

  static const String statusOpen = '未處理';
  static const String statusInProgress = '處理中';
  static const String statusResolved = '已解決';
  static const String allStatuses = '全部狀態';

  static const String sourceStudent = '學生回報';
  static const String sourceSystem = '系統偵測';
  static const String sourcePatrol = '巡邏通報';
  static const String allSources = '全部來源';

  static const String typeNoPower = '充電位故障／無法供電';
  static const String typeOccupiedByOther = '充電位被他人佔用';
  static const String typeCable = '充電線或插座損壞';
  static const String typeQr = 'QR Code 無法掃描';
  static const String typeUnscanned = '未掃碼佔用';
  static const String typeUnregistered = '未登記車輛';
  static const String typeDeviceOffline = '充電位設備離線';
  static const String typeOther = '其他';

  static const String noIncidents = '沒有符合條件的案件';
  static const String selectIncident = '請選擇案件以查看詳情';
  static const String fieldId = '案件編號';
  static const String fieldSpot = '充電位';
  static const String fieldSpotStatus = '充電位狀態';
  static const String fieldSource = '來源';
  static const String fieldReportedAt = '回報時間';
  static const String fieldReporter = '回報人';
  static const String fieldInvolved = '相關學生';
  static const String fieldNote = '說明';
  static const String fieldHandler = '處理人員';
  static const String fieldResolvedAt = '解決時間';
  static const String fieldResolution = '處理結果';
  static const String photoPlaceholder = '學生附加照片（預留）';

  static const String startHandling = '開始處理';
  static const String markResolved = '標記已解決';
  static const String resolveTitle = '標記為已解決';
  static const String resolutionLabel = '處理結果說明';
  static const String resolutionHint = '例：已聯繫車主移車';
  static const String confirmResolve = '確認';
  static const String recordPointsForInvolved = '為相關學生記點';
  static const String setSpotOffline = '將充電位設為維修中';
  static const String spotInUse = '充電位使用中，無法設為維修中';
  static String incidentStarted(String id) => '$id 已開始處理';
  static String incidentResolved(String id) => '$id 已標記為已解決';

  // ----------------------------------------------------------- 外觀
  static const String themeToLight = '切換為淺色模式';
  static const String themeToDark = '切換為深色模式';
}
