/**
 * 活動のイベント内容を送る機能
 */
 public without sharing class auSendEventMailCtrl {

    // 検索：検索用の活動
    public Event searchEvent{get;set;}
    // ログインユーザId
    private Id userId {get;private set;}
    // ログインユーザ情報
    private User myUser {get;private set;}
    // 活動リスト
    public List<Event> eventList{get;set;}
    public Map<Id, Id> mpContentVersion{get;set;}
    // 検索結果のリスト
    public List<result> resultList{get;set;}
    // メールのToアドレスを格納するリスト
    public List<MailAddress> mailToAddressList{get;set;}
    // メールのCCアドレスを格納するリスト
    public List<MailAddress> mailCcAddressList{get;set;}
    // メールのBCCアドレスを格納するリスト
    public List<MailAddress> mailBccAddressList{get;set;}
    // 検索結果から出力したテキストエリア
    public String resultTextArea {get;set;}
    public String resultTextAreaMemo {get;set;}
    // CCメール１
    public String ccAdress1{get;private set;}
    // 手入力
    public String manualInputText{get; set;}
    // パターン名変更
    public String changePatternText{get; set;}
    public String changePatternTextMemo{get; set;}
    // 宛先メールユーザ1
    public auCriteria__c criteria1{get;private set;}
    // パターン保持ボタン名１
    public String patternBtnName1 {get;private set;}
    // パターン保持ボタン名２
    public String patternBtnName2 {get;private set;}
    // パターン保持ボタン名３
    public String patternBtnName3 {get;private set;}
    // パターン保持ボタン名４
    public String patternBtnName4 {get;private set;}
    // パターン保持ボタン名５
    public String patternBtnName5 {get;private set;}
    // メールの件名（テンプレート部分）
    private static final String MAIL_SUBJECT_TEMP = System.Label.auSendEventMail_MSG_01;
    // パターン１
    private static final String DISPLAY_PATTERN_1 = 'パターン１';
    // パターン２
    private static final String DISPLAY_PATTERN_2 = 'パターン２';
    // パターン３
    private static final String DISPLAY_PATTERN_3 = 'パターン３';
    // パターン４
    private static final String DISPLAY_PATTERN_4 = 'パターン４';
    // パターン５
    private static final String DISPLAY_PATTERN_5 = 'パターン５';
    private static final String DISPLAY_PATTERN_LAST = '最新パターン';

    // パターン保持のパラメータ名１
    public String patternParamName1 {get;private set;}
    // パターン保持のパラメータ名２
    public String patternParamName2 {get;private set;}
    // パターン保持のパラメータ名３
    public String patternParamName3 {get;private set;}
    // パターン保持のパラメータ名４
    public String patternParamName4 {get;private set;}
    // パターン保持のパラメータ名５
    public String patternParamName5 {get;private set;}

    public String classInputManualEmail {get;private set;}

    // パターンのセレクト値
    public String patternData {get;set;}
    // パターンのセレクトボックス
    public List<SelectOption> getSelectPattern() {
        List<SelectOption> options = new List<Selectoption>();

        // テンプレートの'テンプレートn'又は保存した文字列をセット
        options.add(new SelectOption(DISPLAY_PATTERN_1, settingPatternName(DISPLAY_PATTERN_1, myUser.MailAddressMemory1__c)));
        options.add(new SelectOption(DISPLAY_PATTERN_2, settingPatternName(DISPLAY_PATTERN_2, myUser.MailAddressMemory2__c)));
        options.add(new SelectOption(DISPLAY_PATTERN_3, settingPatternName(DISPLAY_PATTERN_3, myUser.MailAddressMemory3__c)));
        options.add(new SelectOption(DISPLAY_PATTERN_4, settingPatternName(DISPLAY_PATTERN_4, myUser.MailAddressMemory4__c)));
        options.add(new SelectOption(DISPLAY_PATTERN_5, settingPatternName(DISPLAY_PATTERN_5, myUser.MailAddressMemory5__c)));

        return options;
    }

    /**
     * コンストラクタ
     **/
    public auSendEventMailCtrl () {
        // ユーザIdを取得
        userId = UserInfo.getUserId();
        myUser = [SELECT Id, Name
                , MailAddressMemory1__c //メールアドレス記憶１
                , MailAddressMemory2__c //メールアドレス記憶２
                , MailAddressMemory3__c //メールアドレス記憶３
                , MailAddressMemory4__c //メールアドレス記憶４
                , MailAddressMemory5__c //メールアドレス記憶５
                , MailAddressMemoryLast__c
                FROM USER WHERE Id = :userId];
    }

    /**
     * 初期表示
     */
    public void init() {

        // 初期化
        searchEvent = new Event();
        eventList = new List<Event>();
        resultList = new List<result>();
        criteria1 = new auCriteria__c();
        mailToAddressList = new List<MailAddress>();
        mailCcAddressList = new List<MailAddress>();
        mailBccAddressList = new List<MailAddress>();
        resultTextArea = '';
        ccAdress1 = '';
        manualInputText = '';
        changePatternText = '';
        // テンプレートの'テンプレート１'又は保存した文字列をセット
        patternBtnName1 = settingPatternName(DISPLAY_PATTERN_1,myUser.MailAddressMemory1__c);
        // テンプレートの'テンプレート2'又は保存した文字列をセット
        patternBtnName2 = settingPatternName(DISPLAY_PATTERN_2,myUser.MailAddressMemory2__c);
        // テンプレートの'テンプレート3'又は保存した文字列をセット
        patternBtnName3 = settingPatternName(DISPLAY_PATTERN_3,myUser.MailAddressMemory3__c);
        // テンプレートの'テンプレート4'又は保存した文字列をセット
        patternBtnName4 = settingPatternName(DISPLAY_PATTERN_4,myUser.MailAddressMemory4__c);
        // テンプレートの'テンプレート5'又は保存した文字列をセット
        patternBtnName5 = settingPatternName(DISPLAY_PATTERN_5,myUser.MailAddressMemory5__c);
        // テンプレートのパラメータ名を設定
        patternParamName1 = DISPLAY_PATTERN_1;
        patternParamName2 = DISPLAY_PATTERN_2;
        patternParamName3 = DISPLAY_PATTERN_3;
        patternParamName4 = DISPLAY_PATTERN_4;
        patternParamName5 = DISPLAY_PATTERN_5;

        settingTextArea(myUser.MailAddressMemoryLast__c);
        changePatternText = '';

        // ユーザに紐づくイベントを取得
        eventList = getEventSearch(Date.today(), Date.today());

    }
    /**
     * 活動を検索
     */
    public PageReference search() {

        Boolean errorFlg = errorValidate();
        if (errorFlg) {
            return null;
        }

        // 検索条件で絞り込んだ活動を取得する
        List<Event> eventList = getEventSearch(criteria1.StartDate__c, criteria1.EndDate__c);

        resultList = new List<result>();
        system.debug(eventList.size());
        // 検索結果が０件の場合エラー
        if (eventList.isEmpty()) {
            //検索結果が０件です。検索条件を変更して再度検索してください。
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_02));
            return null;
        } else {
            // 検索結果用のリストを作成する。
            for (Event ev : eventList) {
                resultList.add(new result(ev));
            }
            system.debug(resultList.size());
            return null;
        }
    }
   /**
     * 検索結果の内容をテキストエリアに追加する
     **/
     public void addResultToTextArea () {
        for (result re : resultList) {
            if (re.checked) {
                if (resultTextArea.length() != 0) {
                    resultTextArea += '\n';
                }
                if (!re.event.IsAllDayEvent) {
                    resultTextArea += re.event.StartDateTime.format('yyyy-MM-dd HH:mm') + ' ～ ' + re.event.EndDateTime.format('yyyy-MM-dd HH:mm') + '\n';
                } else {
                    resultTextArea += re.event.StartDateTime.format('yyyy-MM-dd') + ' ～ ' + re.event.EndDateTime.format('yyyy-MM-dd') + '\n';
                }
                resultTextArea += re.event.Subject + '\n';
                if (re.event.Description != NULL) {
                    resultTextArea += re.event.Description + '\n';
                }

                if (re.event.AuNewMNP__c != NULL || re.event.AuNewTablet__c != NULL || re.event.AuNewRooter__c != NULL || re.event.AuModelChange__c != NULL || re.event.AuTotal__c != NULL) {
                    resultTextArea += '＜au＞' + '\n';
                }
                if (re.event.AuNewMNP__c != NULL) {
                    resultTextArea += '  新規：合計 - ' + re.event.AuNewMNP__c + '件' + '\n';
                }
                if (re.event.AuNewTablet__c != NULL) {
                    resultTextArea += '  新規：ハンドセット - ' + re.event.AuNewTablet__c + '件' + '\n';
                }
                if (re.event.AuNewRooter__c != NULL) {
                    resultTextArea += '  新規：MNP - ' + re.event.AuNewRooter__c + '件' + '\n';
                }
                if (re.event.AuModelChange__c != NULL) {
                    resultTextArea += '  機変 - ' + re.event.AuModelChange__c + '件' + '\n';
                }
                if (re.event.AuTotal__c != NULL) {
                    resultTextArea += '  総販 - ' + re.event.AuTotal__c + '件' + '\n';
                }

                if (re.event.BBCHikari__c != NULL || re.event.BBCCableTosu__c != NULL) {
                    resultTextArea += '＜BBC＞' + '\n';
                }
                if (re.event.BBCHikari__c != NULL) {
                    resultTextArea += '  BBC：ひかり - ' + re.event.BBCHikari__c + '件' + '\n';
                }
                if (re.event.BBCCableTosu__c != NULL) {
                    resultTextArea += '  BBC：ケーブルトス - ' + re.event.BBCCableTosu__c + '件' + '\n';
                }

                if (re.event.UQ_2__c != NULL || re.event.UQ_3__c != NULL) {
                    resultTextArea += '＜UQモバイル成約実績 = 新規加入+sim単体販売実績＞　　※UQモバイル取扱い店のみご報告をお願い致します。' + '\n';
                }
                if (re.event.UQ_2__c != NULL) {
                    resultTextArea += '  UQモバイル：auスタッフ直取 - ' + re.event.UQ_2__c + '件' + '\n';
                }
                if (re.event.UQ_3__c != NULL) {
                    resultTextArea += '  UQモバイル：UQ振り成約実績 - ' + re.event.UQ_3__c + '件' + '\n';
                }

                if (re.event.auDenki__c != NULL || re.event.WALLET_Market__c != NULL || re.event.WaterServer__c != NULL) {
                    resultTextArea += '＜ライフデザイン関連商材＞　　※WALLET Market商材については、取扱い店のみご報告をお願い致します。' + '\n';
                }
                if (re.event.auDenki__c != NULL) {
                    resultTextArea += '  auでんき - ' + re.event.auDenki__c + '件' + '\n';
                }
                if (re.event.WALLET_Market__c != NULL) {
                    resultTextArea += '  WALLET Market - ' + re.event.WALLET_Market__c + '円' + '\n';
                }
                if (re.event.WaterServer__c != NULL) {
                    resultTextArea += '  ウォーターサーバー - ' + re.event.WaterServer__c + '件' + '\n';
                }

                if (re.event.ContentDocumentLinks != NULL && re.event.ContentDocumentLinks.size() > 0) {
                    for (ContentDocumentLink cdl : re.event.ContentDocumentLinks) {
                        if (mpContentVersion.containsKey(cdl.ContentDocumentId)) {
                            resultTextArea += '□ ' + auCommunityCustomSettings__c.getOrgDefaults().DownloadFileUrl__c + mpContentVersion.get(cdl.ContentDocumentId) + '\n';
                        }
                    }
                }

            }
        }
        system.debug(resultTextArea);
     }

    /**
     * ユーザ事に保存されたパターンを取得し、アドレスを設定する
     **/
    public void acquisition(){
        system.debug(patternData);
        // パターンを保存した１番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_1.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory1__c);
        }
        // パターンを保存した２番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_2.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory2__c);
        }
        // パターンを保存した３番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_3.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory3__c);
        }
        // パターンを保存した４番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_4.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory4__c);
        }
        // パターンを保存した５番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_5.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory5__c);
        }

    }

    /**
     *　パターン名の設定
     * @param tempStr　テンプレートの文字列
     * @param memoryStr 保存した文字列
     **/
     public String settingPatternName (String tempStr, String memoryStr) {
        String returnStr = tempStr;
        if (memoryStr != null) {
            // 保存した文字列が１桁以上且つ開始文字が[TO]以外
            if (memoryStr.length()>0 && !memoryStr.startsWith('[TO]')) {
                // 保存した文字列に[TO]が含まれている場合
                if (memoryStr.indexOf('[TO]') >= 0){
                    returnStr = memoryStr.subString(0,memoryStr.indexOf('[TO]'));
                // 含まれていない場合、パターン名しか記憶していない
                } else {
                    returnStr = memoryStr;
                }
            }
        }
        return returnStr;
     }

    /**
     * 保持した文字列をテキストエリアに変換に各項目にセットする
     * @param memoryStr　保持したアドレス群
     **/
        public void settingTextArea (String memoryStr) {
            system.debug(memoryStr);
            mailToAddressList = new List<MailAddress>();
            mailCcAddressList = new List<MailAddress>();
            mailBccAddressList = new List<MailAddress>();
            changePatternText = '';
        //[TO][CC][BCC]の合計数１３以下の場合、空なためクリアした状態上書き
        if (memoryStr!=null) {
            // [TO]を含めたtoアドレス末尾までの件数
            Integer toCount = memoryStr.indexOf('[TO]');
            // [TO]を含めたtoアドレス末尾までの件数
            Integer ccCount = memoryStr.indexOf('[CC]');
            // [TO][CC]を含めたtoアドレス+CCアドレス末尾までの件数
            Integer bccCount = memoryStr.indexOf('[BCC]');

            if (toCount >= 0){
                changePatternText = memoryStr.subString(0, toCount);
            } else {
                changePatternText = memoryStr;
            }

            String memoryToStr = memoryStr.subString(toCount+4,ccCount); //[TO]=4文字から[CC]を含まない範囲を抜出
            String memoryCCStr = memoryStr.subString(ccCount+4,bccCount); //上記+[CC]=4文字から[BCC]を含まない範囲を抜出
            String memoryBCCStr = memoryStr.subString(bccCount+5,memoryStr.length()); //上記+[BCC]=5文字から末尾まで抜出
            system.debug(memoryToStr);
            system.debug(memoryCCStr);
            system.debug(memoryBCCStr);
            // To,CC,BCC事にリストを分ける
            List<String> inputToList = memoryToStr.split(',', 0);
            List<String> inputCcList = memoryCCStr.split(',', 0);
            List<String> inputBccList = memoryBCCStr.split(',', 0);


            // Get the list of all users ID
            List<Id> lsUsrID = new List<ID>();
            if (memoryToStr.length() > 0) {
                for (String to : inputToList) {
                    if (!to.startsWith('手入力')) {
                        lsUsrID.add(to);
                    }
                }
            }
            if (memoryCCStr.length() > 0) {
                for (String to : inputCcList) {
                    if (!to.startsWith('手入力')) {
                        lsUsrID.add(to);
                    }
                }
            }
            if (memoryBCCStr.length() > 0) {
                for (String to : inputBccList) {
                    if (!to.startsWith('手入力')) {
                        lsUsrID.add(to);
                    }
                }
            }

            Map<String,String> fullUserMap = new Map<String,String>();
            List<User> fullUser = [SELECT Id, Name, Email FROM User WHERE IsActive = true and Id in :lsUsrID];
            for (User full : fullUser) {
                fullUserMap.put(String.valueOf(full.Id),full.Name + ',' + full.Email);
            }


            // TOアドレス欄に入力があった場合
            if (memoryToStr.length() > 0) {
                for (String to : inputToList) {
                    //アドレス欄の先頭に手入力の文字がある場合
                    if (to.startsWith('手入力')) {
                        mailToAddressList.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                    //アドレス欄の先頭に手入力の文字がない場合
                    } else {
                        String nameEmailStr = fullUserMap.get(to);
                        String[] nameEmailList = nameEmailStr.split(',',0);
                        mailToAddressList.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                    }
                }
            } else {
                mailToAddressList = new List<MailAddress>();
            }
            // CCアドレス欄に入力があった場合
            if (memoryCCStr.length() > 0) {
                for (String to : inputCcList) {
                    //アドレス欄の先頭に手入力の文字がある場合
                    if (to.startsWith('手入力')) {
                        mailCcAddressList.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                    //アドレス欄の先頭に手入力の文字がない場合
                    } else {
                        String nameEmailStr = fullUserMap.get(to);
                        String[] nameEmailList = nameEmailStr.split(',',0);
                        mailCcAddressList.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                    }
                }
            } else {
                mailCcAddressList = new List<MailAddress>();
            }
            // BCCアドレス欄に入力があった場合
            if (memoryBCCStr.length() > 0) {
                for (String to : inputBccList) {
                    //アドレス欄の先頭に手入力の文字がある場合
                    if (to.startsWith('手入力')) {
                        mailBccAddressList.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                    //アドレス欄の先頭に手入力の文字がない場合
                    } else {
                        String nameEmailStr = fullUserMap.get(to);
                        String[] nameEmailList = nameEmailStr.split(',',0);
                        mailBccAddressList.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                    }
                }
            } else {
                mailBccAddressList = new List<MailAddress>();
            }

        }
    }
    /**
     * 押下したボタンによってアドレスを追加
     **/
    public PageReference addAddress() {
        //アドレスの種類
        String kindAddress = System.currentPageReference().getParameters().get('parameter');
        //手入力から取得なのかルックアップから取得なのか
        String inputType = System.currentPageReference().getParameters().get('inputParam');
system.debug(kindAddress);
system.debug(inputType);
system.debug(criteria1.User__c);

        //  ユーザのルックアップから取得の場合
        if (inputType != 'manual') {
            // 登録ユーザが未選択だった場合
            if (criteria1.User__c == null) {
                //登録ユーザを選択してください。
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_03));
                return null;
            } else {
                // 登録ユーザを取得する
                User user = [SELECT Id,Name,Email FROM User WHERE Id =:criteria1.User__c];
                system.debug(user.Email);

                // toAddを押下した場合テキストエリアにEmailアドレスをセットする。
                if (kindAddress.equals('toAdd')) {
                    mailToAddressList.add(new MailAddress(String.ValueOf(user.Id),user.Name,user.Email));
                }
                // ccAddを押下した場合テキストエリアにEmailアドレスをセットする。
                if (kindAddress.equals('ccAdd')) {
                    mailCcAddressList.add(new MailAddress(String.ValueOf(user.Id),user.Name,user.Email));
                }
                // bccAddを押下した場合テキストエリアにEmailアドレスをセットする。
                if (kindAddress.equals('bccAdd')) {
                    mailBccAddressList.add(new MailAddress(String.ValueOf(user.Id),user.Name,user.Email));
                }
            }

        // 手入力から取得の場合
        } else {

            classInputManualEmail = '';

            // 手入力が未入力だった場合
            if (manualInputText.length() == 0) {
                //手入力にメールアドレスを入力してください。
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_04));
                return null;
            }
            if (!validateEmail(manualInputText)) {
                //手入力にメールアドレスを入力してください。
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '手入力に正しいメールアドレスを入力してください。'));
                classInputManualEmail = 'error';
                return null;
            }

            String[] manualList = manualInputText.split(',',0);
        //@todo []の入力チェックは必須。メールアドレスのチェックができればなおよし

            for (String manual : manualList) {
                // toAddを押下した場合テキストエリアにEmailアドレスをセットする。
                if (kindAddress.equals('toAdd')) {
                    //if(toAddressArea.length()>0){toAddre
                    mailToAddressList.add(new MailAddress(null,'手入力',manual));
                }
                // ccAddを押下した場合テキストエリアにEmailアドレスをセットする。
                if (kindAddress.equals('ccAdd')) {
                    mailCcAddressList.add(new MailAddress(null,'手入力',manual));
                }
                // bccAddを押下した場合テキストエリアにEmailアドレスをセットする。
                if (kindAddress.equals('bccAdd')) {
                    mailBccAddressList.add(new MailAddress(null,'手入力',manual));
                }
            }
        }

        //@todo 登録数の上限を決める必要あり？

        return null;
    }

    /**
     * 指定したテキストエリアをクリアする
     **/
     public void textClear() {
        //アドレスの種類
        String kindAddress = System.currentPageReference().getParameters().get('parameter');
        // TOのテキストエリアをクリア
        if (kindAddress.equals('toClear')) {
            //toAddressArea = '';
            mailToAddressList = new List<mailAddress>();
        }
        // CCのテキストエリアをクリア
        if (kindAddress.equals('ccClear')) {
            //ccAddressArea = '';
            mailCcAddressList = new List<mailAddress>();
        }
        // BCCのテキストエリアをクリア
        if (kindAddress.equals('bccClear')) {
            //bccAddressArea = '';
            mailBccAddressList = new List<mailAddress>();
        }
     }


     public PageReference pattern1Save() {
        return patternSaveFunc(DISPLAY_PATTERN_1);
     }
     public PageReference pattern2Save() {
        return patternSaveFunc(DISPLAY_PATTERN_2);
     }
     public PageReference pattern3Save() {
        return patternSaveFunc(DISPLAY_PATTERN_3);
     }
     public PageReference pattern4Save() {
        return patternSaveFunc(DISPLAY_PATTERN_4);
     }
     public PageReference pattern5Save() {
        return patternSaveFunc(DISPLAY_PATTERN_5);
     }

     /**
      * パターンを保存する
      **/
     private PageReference patternSaveFunc(String patternName) {

        changePatternText = changePatternTextMemo;

        String joinToAddress = '';
        String joinCcAddress = '';
        String joinBccAddress = '';

        // パターン保存に使用する区切り文字が入っていた場合エラー
        if (validatePatternNameCheck(changePatternText)) {
            //[]が入った内容は保存できません。他の文字を使用してください。
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_05));
            return null;
        }

        // TOアドレス欄
        for (mailAddress mail : mailToAddressList) {
            String toInputStr = '';
            // 手入力かルックアップからの取得か判別
            if (mail.userId != null) {
                toInputStr = String.valueOf(mail.userId);
            } else {
                toInputStr = '手入力' + mail.email;
            }
            // ２回目以降は区切り文字を先頭につけて追記する
            if (joinToAddress.length() == 0) {
                joinToAddress += toInputStr;
            } else {
                joinToAddress += ',' + toInputStr;
            }
        }
        // CCアドレス欄
        for (mailAddress mail : mailCcAddressList) {
            String ccInputStr = '';
            // 手入力かルックアップからの取得か判別
            if (mail.userId != null) {
                ccInputStr = String.valueOf(mail.userId);
            } else {
                ccInputStr = '手入力' + mail.email;
            }
            // ２回目以降は区切り文字を先頭につけて追記する
            if (joinCcAddress.length() == 0) {
                joinCcAddress += ccInputStr;
            } else {
                joinCcAddress += ',' + ccInputStr;
            }
        }
        // BCCアドレス欄
        for (mailAddress mail : mailBccAddressList) {
            String bccInputStr = '';
            // 手入力かルックアップからの取得か判別
            if (mail.userId != null) {
                bccInputStr = String.valueOf(mail.userId);
            } else {
                bccInputStr = '手入力' + mail.email;
            }
            // ２回目以降は区切り文字を先頭につけて追記する
            if (joinBccAddress.length() == 0) {
                joinBccAddress += bccInputStr;
            } else {
                joinBccAddress += ',' + bccInputStr;
            }
        }
        String memoryStr = '';
        memoryStr = changePatternText + '[TO]'+ joinToAddress //TOのアドレス群
                                            + '[CC]' + joinCcAddress //CCのアドレス群
                                            + '[BCC]' + joinBccAddress; //BCCのアドレス群

        //  テキスト最大桁数の131072を超える場合エラー
        if (memoryStr.length() > 131072) {
            //メールアドレスの桁数が多すぎて登録できません。
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_06));
            return null;
        } else {
            // パターン１の場合
            if (patternName.equals(DISPLAY_PATTERN_1)) {
                myUser.MailAddressMemory1__c = memoryStr; //メモリ１に登録
                patternBtnName1 = changePatternText.length() > 0 ? changePatternText : DISPLAY_PATTERN_1;      //画面表示用のボタン更新
            }
            // パターン２の場合
            if (patternName.equals(DISPLAY_PATTERN_2)) {
                myUser.MailAddressMemory2__c = memoryStr; //メモリ２に登録
                patternBtnName2 = changePatternText.length() > 0 ? changePatternText : DISPLAY_PATTERN_2;      //画面表示用のボタン更新
            }
            // パターン３の場合
            if (patternName.equals(DISPLAY_PATTERN_3)) {
                myUser.MailAddressMemory3__c = memoryStr; //メモリ３に登録
                patternBtnName3 = changePatternText.length() > 0 ? changePatternText : DISPLAY_PATTERN_3;      //画面表示用のボタン更新
            }
            // パターン４の場合
            if (patternName.equals(DISPLAY_PATTERN_4)) {
                myUser.MailAddressMemory4__c = memoryStr; //メモリ４に登録
                patternBtnName4 = changePatternText.length() > 0 ? changePatternText : DISPLAY_PATTERN_4;      //画面表示用のボタン更新
            }
            // パターン５の場合
            if (patternName.equals(DISPLAY_PATTERN_5)) {
                myUser.MailAddressMemory5__c = memoryStr; //メモリ５に登録
                patternBtnName5 = changePatternText.length() > 0 ? changePatternText : DISPLAY_PATTERN_5;      //画面表示用のボタン更新
            }
            // パターン５の場合
            if (patternName.equals(DISPLAY_PATTERN_LAST)) {
                myUser.MailAddressMemoryLast__c = memoryStr;
            }
            try {
                update myUser;
            } catch (Exception e) {
                system.debug(e.getMessage());
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'システムエラーが発生しました。システム管理者にお問い合わせください。'));
            }

        }
        getSelectPattern();
        //パターンを保存しました。
        if (patternName != DISPLAY_PATTERN_LAST) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.Label.auSendEventMail_MSG_07));
        }
        return null;

     }



     /**
      * パターン名禁止文字チェック
      * @param ptnName パターン名
      * @return true:エラーあり、false:エラーなし
      **/
     public Boolean validatePatternNameCheck (String ptnName) {

        Boolean errorFlg = false;

        if (ptnName.indexOf('[')>=0 || ptnName.indexOf(']')>=0) {
            errorFlg = true;
        }

        return errorFlg;
     }

    /**
     * 活動内容をメールで送信
     */
     public PageReference sendMail() {

        resultTextArea = resultTextAreaMemo;

        List<User> onlyToUser = new List<User>();
        Id onlyToUserId = null;
        Boolean onlyToFlg = false;
        // Toが未選択の場合エラー
        if (mailToAddressList.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_08));
            return null;
        }
        if (resultTextArea == NULL || resultTextArea.trim().length() == 0) {
            //Toが全て未選択の場合送信できません。１つ以上選択してください。
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'メール本文を入力してください。'));
            return null;
        }
        //@todo []の入力チェックは必須。メールアドレスのチェックができればなおよし
        //Boolean isEmail = Pattern.matches('^[a-zA-Z0-9]',ccAdress1);
        String[] emailStrList = new String[0];
        String[] mailCcStrList = new String[0];
        String[] mailBccStrList = new String[0];

        //if (toAddressList.size() > 0) {
        //    emailStrList = (String.join(toAddressList,',')).split(',', 0);
        //}
        //if (ccAddressList.size() > 0) {
        //    mailCcStrList = (String.join(ccAddressList,',')).split(',', 0);
        //}
        //if (bccAddressList.size() > 0) {
        //    mailBccStrList = (String.join(bccAddressList,',')).split(',', 0);
        //}

        if (mailToAddressList.size() > 0) {
            String mailToStr = '';
            for (mailAddress to : mailToAddressList) {
                system.debug(to.email);
                if (mailToStr == '') {
                    mailToStr += to.email;
                } else {
                    mailToStr += ',' + to.email;
                }
            }
            system.debug(mailToStr);
            emailStrList = mailToStr.split(',',0);
        }
        if (mailCcAddressList.size() > 0) {
            String mailCcStr = '';
            for (mailAddress cc : mailCcAddressList) {
                if (mailCcStr == '') {
                    mailCcStr += cc.email;
                } else {
                    mailCcStr += ',' + cc.email;
                }
            }
            system.debug(mailCcStr);
            mailCcStrList = mailCcStr.split(',',0);
        }
        if (mailBccAddressList.size() > 0) {
            String mailBccStr = '';
            for (mailAddress bcc : mailBccAddressList) {
                if (mailBccStr == '') {
                    mailBccStr += bcc.email;
                } else {
                    mailBccStr += ',' + bcc.email;
                }
            }
            system.debug(mailBccStr);
            mailBccStrList = mailBccStr.split(',',0);
        }

        // メール本文用のテキストエリアをセットする
        String bodyStr = resultTextArea;

        system.debug(bodyStr);
        try {
            system.debug(emailStrList.size());
            system.debug(mailCcStrList.size());
            system.debug(mailBccStrList.size());
            auSendEmailUtil cls = new auSendEmailUtil();
            // 宛先が一件だけの場合
            if (emailStrList.size() == 1
                && mailCcStrList.size()==0
                && mailBccStrList.size()==0) {
                String emailStr = emailStrList[0];
                onlyToUser = [SELECT Id FROM User WHERE Email =:emailStr];
                // Toが１件且つ存在しているユーザだった場合targetobjectIdのフラグオン
                if (!onlyToUser.isEmpty()) {
                    onlyToUserId = onlyToUser[0].Id;
                    onlyToFlg = true;
                }
            }
            cls.createTOCCBCCSendMessage(null,String.valueOf(onlyToUserId),emailStrList,mailCcStrList,mailBccStrList
                ,MAIL_SUBJECT_TEMP + myUser.Name,bodyStr,onlyToFlg);

            List<auSendEmailUtil.SendResponse> lsResp = cls.sendMail();
            boolean hasError = false;
            String errorMessage = '';
            for (auSendEmailUtil.SendResponse resp : lsResp) {
                if (!resp.success) {
                    hasError = true;
                    errorMessage = resp.message;
                }
            }

            if (!hasError) {
                patternSaveFunc(DISPLAY_PATTERN_LAST);
                //メールを送信しました。
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.auSendEventMail_MSG_09));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.auSendEventMail_MSG_10 + '\n' + errorMessage));
            }

       } catch (Exception e) {
            system.debug(e.getMessage());
            //メールの送信に失敗しました。メールアドレスの確認又はシステム管理者にお問い合わせください。
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.auSendEventMail_MSG_10));
        }
            return null;
    }

    /**
     * 入力条件から活動を取得する
     * @param Datetime sDate
     * @param Datetime eDate
     */
    public List<Event> getEventSearch(Date sDate, Date eDate) {

        List<Event> evList = new List<Event>();
        String startDate = null;
        String endDate = null;
        String queryStr  = '';
        String selectStr = ' SELECT Id, Subject, Description, StartDateTime, EndDateTime, IsAllDayEvent, ActivityDate, (SELECT Id, ContentDocumentId FROM ContentDocumentLinks), ' +
                           '        AuNewMNP__c, AuNewTablet__c, AuNewRooter__c, AuModelChange__c, AuTotal__c, BBCHikari__c, BBCCableTosu__c, UQ_2__c, UQ_3__c, auDenki__c, ' +
                           '        WALLET_Market__c, WaterServer__c';
        String fromStr   = ' FROM Event ';
        String whereStr  = ' WHERE ownerId = \'' + userId + '\'';
        String orderStr  = ' ORDER BY ActivityDate, IsAllDayEvent desc, StartDateTime';

        // Note: for GMT-xx, this algorithm does not work for All Day events
        if (sDate != null) {
            Datetime sDateTime = Datetime.newInstance(sDate.year(), sDate.month(), sDate.day());
            startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            whereStr += ' And EndDateTime > ' + startDate;
        }

        if (eDate != null) {
            eDate = eDate.addDays(1);
            Datetime sEndTime = Datetime.newInstance(eDate.year(), eDate.month(), eDate.day());
            endDate = sEndTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            whereStr += ' And StartDateTime <= ' + endDate;
        }

        queryStr = selectStr + fromStr + whereStr + orderStr;

        system.debug('検索SOQL'+queryStr);
        evList = Database.query(queryStr);

        system.debug('検索結果数'+evList.size());
        // 活動が空の場合
        if (evList.isEmpty()) {
            evList = new List<Event>();
        }


        List<Id> lsId = new List<Id>();

        // 検索結果をセットする
        for (Event ev : evList) {
            resultList.add(new result(ev));
            if (ev.ContentDocumentLinks != NULL && ev.ContentDocumentLinks.size() > 0) {
                for (ContentDocumentLink cdl : ev.ContentDocumentLinks) {
                    lsId.add(cdl.ContentDocumentId);
                }
            }
        }

        List<ContentVersion> lsContentVersion = new List<ContentVersion>();
        if (lsId != NULL && lsId.size() > 0) {
            lsContentVersion = [SELECT Id, ContentDocumentId from ContentVersion where ContentDocumentId IN :lsId];
        }

        mpContentVersion = new Map<Id, Id>();
        for (ContentVersion cv : lsContentVersion) {
            mpContentVersion.put(cv.ContentDocumentId, cv.Id);
        }



        return evList;
    }

    /**
     * 検索の入力チェック
     */
    public Boolean errorValidate(){
        Boolean errorflg = false;

        // 開始日時 > 終了日時だった場合エラー
        if (criteria1.StartDate__c > criteria1.EndDate__c) {
            //開始日は終了日より前の日を入力してください。
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.auSendEventMail_MSG_11));
            errorflg = true;
        }

        return errorflg;
    }

    /**
     * 検索結果用のインナークラス
     */
     private class result {

        // 検索結果のチェック内容
        public Boolean checked{get;set;}
        public Date startDate{get;set;}
        public Date endDate{get;set;}
        // 検索結果の行動情報
        public Event event{get;set;}

        public result (Event resultEvent) {
            checked = false;
            event = resultEvent;
            if (resultEvent.StartDateTime != NULL) {
                startDate = resultEvent.StartDateTime.date();
            }
            if (resultEvent.EndDateTime != NULL) {
                endDate = resultEvent.EndDateTime.date();
            }
         }
     }

     /**
     * メールアドレス用のインナークラス
     */
     private class MailAddress {
        // 送信対象のユーザID
        public String userId{get;set;}
        // 送信対象のユーザ名
        public String userName{get;set;}
        // 送信対象のメールアドレス
        public String email{get;set;}

        public MailAddress () {
            userId = null;
            userName = null;
            email = null;
        }

        public MailAddress (String Id,String Name,String mail) {
            userId = Id;
            userName = Name;
            email = mail;
        }
    }

    private static Boolean validateEmail(String email) {

        Boolean res = true;                    
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        if (!Pattern.compile(emailRegex).matcher(email).matches()) 
            res = false;
        return res; 

    }

 }