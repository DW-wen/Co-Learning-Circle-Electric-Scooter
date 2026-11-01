// 學生端介面文字 —— 繁體中文（台灣）
//
// All student-facing text lives here so wording can be reviewed in one place.
// To add another language later, migrate these to ARB files (flutter gen-l10n);
// the keys below map 1:1 to ARB message names.

class S {
  S._();

  // ------------------------------------------------------------- app / nav
  static const String appTitle = '校園學生服務';
  static const String navCharging = '充電';
  static const String navViolations = '違規';
  static const String navStation = '充電站';

  /// Dev-only preview strip.
  static const String previewState = '預覽狀態：';

  /// e.g. 夜讀區充電站 · 02 號充電位
  static String spotName(String station, String label) =>
      '$station · $label 號充電位';

  static const String cancel = '取消';

  // ---------------------------------------------------------- 充電（我的充電）
  static const String chargingTitle = '我的充電';
  static const String previewCharging = 'A · 充電中';
  static const String previewFinished = 'B · 充電完成';
  static const String previewNotCharging = '未充電';

  static const String currentStatus = '目前狀態';
  static const String badgeCharging = '充電中';
  static const String badgeFinished = '充電完成';
  static const String badgeNotCharging = '未充電';
  static const String noActiveSession = '目前沒有使用中的充電位\n請至充電站掃描 QR Code 開始充電';
  static const String findSpot = '尋找充電位';

  static const String elapsed = '已充電時間';
  static const String estRemaining = '預估剩餘時間';
  static const String anyMoment = '即將完成';
  static String startedEstDone(String start, String done) =>
      '$start 開始 · 預計 $done 完成';
  static String chargingLimitNote(int hours) => '單次充電上限 $hours 小時';

  static const String elapsedSinceFinished = '充電完成後已經過';
  static String finishedAt(String time) => '完成時間：$time';
  static String moveBy(String time, String left) =>
      '請於 $time 前移車（剩餘 $left，時限暫定）';
  static String moveOverdue(String over) => '已超過移車時限 $over，可能會被記違規點數';

  // 操作
  static const String stopAndUnlock = '結束充電並解鎖';
  static const String unlockAndLeave = '解鎖並離開';
  static const String report = '回報問題';
  static const String endEarlyTitle = '提前結束充電？';
  static const String endEarlyBody = '充電尚未完成。結束後將停止供電並解鎖充電位，'
      '請拔除充電線並將車輛駛離。';
  static const String unlockTitle = '解鎖充電位？';
  static const String unlockBody = '解鎖後請拔除充電線，並將車輛駛離充電位。';
  static const String confirmUnlock = '確認解鎖';
  static const String unlockedThanks = '充電位已解鎖，感謝使用！';

  // 提醒
  static const String reminders = '通知提醒';
  static const String notifyDone = '充電完成時通知我';
  static String notifyMove(int minutes) => '充電完成 $minutes 分鐘後提醒我移車';
  static const String pushTbd = '推播通知尚未串接（線框稿）';

  // 上次充電
  static const String lastSuccessfulCharge = '上次成功充電';
  static const String completedAt = '完成時間';
  static const String chargeDuration = '充電時長';
  static const String spot = '充電位';
  static const String noChargeYet = '尚無成功充電紀錄';

  // ---------------------------------------------------------------- 違規
  static const String violationsTitle = '違規狀態';
  static const String previewAllowed = '可使用＋有記點';
  static const String previewRestricted = '停權中';
  static const String previewClean = '無違規';

  static const String currentStanding = '目前使用資格';
  static const String badgeAllowed = '可使用服務';
  static const String badgeRestricted = '停權中';
  static const String activeViolations = '有效違規';
  static const String yes = '有';
  static const String no = '無';
  static const String rules = '適用規範';
  static const String rulesNightStudy = '夜讀區使用規範';

  static const String accumulatedPoints = '累計違規點數';
  static String points(int n) => '$n 點';
  static const String suspensionThresholdTbd = '停權門檻：? 點（規則待定）';

  static const String resumeFrom = '恢復使用時間';
  static String timeRemaining(String d) => '剩餘 $d';

  static const String violationHistory = '違規歷史紀錄';
  static const String groupMonth = '月';
  static const String groupWeek = '週';
  static const String groupDay = '日';
  static const String noViolations = '尚無違規紀錄';
  static String groupSummary(int count, int pts) => '$count 筆 · +$pts 點';
  static String weekOf(String date) => '$date 當週';

  // -------------------------------------------------------------- 充電站
  static const String stationTitle = '充電站';
  static const String tabNearby = '附近充電站';
  static const String tabScan = '掃碼充電';
  static const String tabHistory = '充電紀錄';

  // 附近充電站
  static const String mapPlaceholder = '地圖預留區\n（校園地圖＋充電站位置）';
  static String stationsNearby(int n) => '附近共 $n 座充電站';
  static String meters(int m) => '$m 公尺';
  static String freeSpots(int free, int total) => '空位 $free/$total';
  static const String full = '已滿';
  static const String spotAvailable = '空位';
  static const String spotCharging = '充電中';
  static const String spotOccupied = '佔用';
  static const String spotOffline = '維修中';
  static String rate(int ntd) => '每小時 NT\$$ntd（暫定）';
  static const String scanHere = '掃碼充電';

  // 掃碼充電
  static const String cameraPlaceholder = '相機取景預留區\n請對準充電位上的 QR Code';
  static const String scanQr = '掃描 QR Code（模擬）';
  static const String orEnterId = '或輸入充電位編號';
  static const String spotIdLabel = '充電位編號';
  static const String spotIdHint = '例：NSA-04';
  static const String unlockSpot = '解鎖充電位';
  static String inSession(String spot) => '您目前正在使用 $spot';
  static const String viewSession = '查看本次充電';
  static String restrictedBanner(String date) => '停權中，$date 起才可使用充電服務';

  static const String rulesTitle = '使用須知';
  static String ruleChargingLimit(int hours) => '單次充電上限 $hours 小時';
  static String ruleMoveAfter(int minutes) => '充電完成後請於 $minutes 分鐘內移車（暫定）';
  static const String ruleScanFirst = '請勿未掃碼即佔用充電位';
  static const String rulePoints = '違規將依夜讀區使用規範記點，累計達門檻將停權';

  // 解鎖結果
  static const String enterSpotId = '請輸入充電位編號。';
  static String unlockedPlugIn(String id) => '$id 已解鎖，請插上充電線開始充電。';
  static const String alreadyInSession = '您已有使用中的充電位，請先結束後再使用其他充電位。';
  static const String restrictedCannotUse = '您目前停權中，無法使用充電服務。';
  static String spotNotFound(String id) => '找不到編號「$id」的充電位。';
  static String spotUnavailable(String id) => '$id 目前無法使用（充電中、佔用或維修中）。';
  static const String noSpotAvailable = '附近目前沒有空的充電位。';

  // 充電紀錄
  static const String queryTitle = '查詢日期';
  static String modeRecent(int months) => '近 $months 個月';
  static const String modeDate = '指定日期';
  static const String dateLabel = '日期（西元 年 - 月 - 日）';
  static String retentionNote(int months, String from) =>
      '可查詢近 $months 個月內的紀錄（$from 起）· 藍點表示當日有紀錄';
  static String daySummary(String date, int count, String total) =>
      '$date · 共 $count 次充電 · 合計充電 $total';
  static const String noRecordsOnDate = '此日期沒有充電紀錄';
  static const String noHistory = '尚無充電紀錄';
  static String historySummary(int count, String total) =>
      '共 $count 次充電 · 合計充電 $total';
  static String charged(String d) => '充電 $d';
  static String parked(String d) => '停放 $d';
  static String fee(int ntd) => 'NT\$$ntd';
  static const String stoppedEarly = '提前結束';
  static String overstay(String d) => '完成後佔用 $d';

  // ------------------------------------------------------------ 回報問題
  static const String reportTitle = '回報問題';
  static const String issueType = '問題類型';
  static const List<String> issueTypes = [
    '充電位故障／無法供電',
    '充電位被他人佔用',
    '充電線或插座損壞',
    'QR Code 無法掃描',
    '其他',
  ];
  static const String spotIdOptional = '充電位編號（選填）';
  static const String noteOptional = '補充說明（選填）';
  static const String photoPlaceholder = '＋ 附加照片（預留）';
  static const String submitReport = '送出回報';
  static const String reportSent = '已送出回報，駐警隊將盡快處理。';
}
