public with sharing class auScheduleCtrl {

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

    private static final String MAIL_SUBJECT_TEMP = System.Label.auSendEventMail_MSG_01;

    public boolean isIPhone {get;set;}
    private Date dCurrentMonth;
    private Date dCurrentDay;

    public String createEventParam1 {get;set;}
    public String createEventParam2 {get;set;}
    public String showDayParam1 {get;set;}
    public String deleteEventParam1 {get;set;}
    public String messageError {get;set;}

    public String currentUserOrganization {get;set;}
    public List<User> lsUsrOwnGroup {get;set;}
    public List<User> lsUsrOtherGroup {get;set;}
    public String otherDepartmentCode {get;set;}

    public String resultTextArea {get;set;}
    public String mailTitle {get;set;}

    public List<clsEventCurrentDay> clsDayCurrentDay {get;set;}
    public boolean isCurrentDaySent {get;set;}
    public boolean isCopyToCCP {get;set;}
    public Map<Id, Id> mpContentVersion{get;set;}

    public List<List<clsDay>> lsDaysOfMonth {get;set;}


    public User myUser {get;private set;}
    public String patternData {get;set;}
    public String patternDataToSend {get;set;}

    // メールのToアドレスを格納するリスト
    public List<MailAddress> mailToAddressList{get;set;}
    // メールのCCアドレスを格納するリスト
    public List<MailAddress> mailCcAddressList{get;set;}
    // メールのBCCアドレスを格納するリスト
    public List<MailAddress> mailBccAddressList{get;set;}

    public List<MailAddress> mailToAddressListConfirm{get;set;}
    public List<MailAddress> mailCcAddressListConfirm{get;set;}
    public List<MailAddress> mailBccAddressListConfirm{get;set;}

    public String mailToManualList {get;set;}
    public String mailCcManualList {get;set;}
    public String mailBccManualList {get;set;}

    public String classInputManualEmailTo {get;set;}
    public String classInputManualEmailCc {get;set;}
    public String classInputManualEmailBcc {get;set;}

    // パターン名変更
    public String changePatternText{get; set;}
    public String changePatternTextNewName{get; set;}

    public String emailSignature{get; set;}
    public String emailHeader{get; set;}

    public String currentMailList{get; set;} // Indicates which mail list (To / Cc / Bcc) we are currenly using
    public List<Attachment> lsAttachment {get; set;}
    public String urlReportsSFA {get; set;}


    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_EVENT_SCHEDULE;}

    /*public List<String> lsOrganization {
        get {
            return new List<String> {
            	'C000000',
            	'X011',
            	'X012',
            	'X010',
            	'X014',
            	'X013',
                'X101',
                'X201',
                'X001',
                'X004',
                'X401',
                'X501',
                'X701',
                'X801',
                'X999'

            };
        }
        set;
    }

    public Map<String,String> mpOrganization {
        get {
            return new Map<String, String> {
            	'C000000' => '本部',
            	'X011' => '特販営業統括部',
            	'X012' => 'トヨタ営業部',
            	'X010' => '広域量販統括部',
            	'X014' => '広域代理店統括1部',
            	'X013' => '広域代理店統括2部',
                'X101' => '北海道支社',
                'X201' => '東北支社',
                'X001' => '関東支社',
                'X004' => '中部北陸支社',
                'X401' => '関西支社',
                'X501' => '中国四国支社',
                'X701' => '九州支社',
                'X801' => '沖縄セルラー電話',
                'X999' => '研修用支社'

            };
        }
        set;
    }*/
    
	public List<String> lsOrganization {
        get {
            return organizationBuildList;
        }
        set;
    }

    public Map<String,String> mpOrganization {
        get {
            return organizationBuildMap;
        }
        set;
    }

	/*Dynamic Organization List*/
	private Map<String, String> organizationBuildMap;
	private List<String> organizationBuildList;
	
    public auScheduleCtrl () {

      messageError = '正しいデーターを入れてください。';
      clsDayCurrentDay = new List<clsEventCurrentDay>();
      isCurrentDaySent = false;

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      urlReportsSFA = auCommunityCustomSettings__c.getOrgDefaults().URLReportsSFA__c;

      dCurrentMonth = Date.today().toStartOfMonth();
      refreshMonth();

      myUser = [SELECT Id, Name
              , MailAddressMemory1__c //メールアドレス記憶１
              , MailAddressMemory2__c //メールアドレス記憶２
              , MailAddressMemory3__c //メールアドレス記憶３
              , MailAddressMemory4__c //メールアドレス記憶４
              , MailAddressMemory5__c //メールアドレス記憶５
              , MailAddressMemoryLast__c
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl
              , Account.RegionalOfficeId__r.RegionalOfficeName__c
              , Account.BranchId__r.BranchName__c
              FROM USER WHERE Id = :UserInfo.getUserId()];

      emailSignature = myUser.Signature;
      emailHeader = myUser.EmailHeader__c;

      /*Dynamic Organization List*/
      List<auOrganization__c> organizationList = [SELECT id, RegionalOfficeCode__c, RegionalOfficeName__c
                                          FROM auOrganization__c
                                          WHERE Category__c = '支社'
                                          AND (DeactivateDate__c = NULL OR DeactivateDate__c > TODAY)
                                          ORDER BY RegionalOfficeCode__c asc];
                                          
      organizationBuildList = new List<String>();
      organizationBuildList.add('C000000'); 
      organizationBuildMap = new Map<String, String>();
      organizationBuildMap.put('C000000','本部'); 
      
      for(auOrganization__c org : organizationList){
      	organizationBuildList.add('X'+org.RegionalOfficeCode__c);
      	organizationBuildMap.put('X'+org.RegionalOfficeCode__c,org.RegionalOfficeName__c); 
      }                                

	  system.debug('organizationBuildList : '+organizationBuildList);
	  system.debug('organizationBuildMap : '+organizationBuildMap);

      if (myUser.UserRole.DeveloperName == auConstantCmn.ROLE_CODE_HONBU) {
        // 本部 Users
        currentUserOrganization = auConstantCmn.ROLE_CODE_HONBU;
      } else {

        Id idHonbu = [SELECT Id FROM UserRole WHERE DeveloperName = :auConstantCmn.ROLE_CODE_HONBU].Id;
        if (myUser.UserRole.ParentRoleId == idHonbu) {
          //支社 users
          currentUserOrganization = myUser.UserRole.DeveloperName;
        } else {
          UserRole ur = [SELECT Id, DeveloperName, ParentRoleId FROM UserRole WHERE Id = :myUser.UserRole.ParentRoleId];
          if (ur.ParentRoleId == idHonbu) {
            // 支店 users
            currentUserOrganization = ur.DeveloperName;
          } else {
            // Should not happen
            currentUserOrganization = auConstantCmn.ROLE_CODE_HONBU;
          }
        }

      }

      List<String> lsShitenShisha = new List<String>();
      lsShitenShisha.add(currentUserOrganization);
      if (currentUserOrganization != auConstantCmn.ROLE_CODE_HONBU) {
        // Get the Id of the role
        Id currentOrdgId = NUll;
        For (UserRole ur : [SELECT Id FROM UserRole WHERE DeveloperName = :currentUserOrganization]) {
          currentOrdgId = ur.Id;
        }

        // Get the list of the Shiten
        for (UserRole ur : [SELECT Id, DeveloperName FROM UserRole WHERE ParentRoleId = :currentOrdgId AND ParentRoleId != NULL]) {
          lsShitenShisha.add(ur.DeveloperName);
        }

      }

      if (currentUserOrganization != auConstantCmn.ROLE_CODE_HONBU) {
        lsUsrOwnGroup = [SELECT Id, Name, Email, TechnicalAlwaysFalse__c, DisplayedUsernameFormula__c, KDDIEmployeeId__c
                         FROM User
                         WHERE UserRole.DeveloperName IN :lsShitenShisha
                         AND IsActive = true
                         ORDER BY Profile.Name, UserRole.DeveloperName, DisplayedUsernameFormula__c];
      } else {
        lsUsrOwnGroup = [SELECT Id, Name, Email, TechnicalAlwaysFalse__c, DisplayedUsernameFormula__c, KDDIEmployeeId__c
                         FROM User
                         WHERE UserRole.DeveloperName IN :lsShitenShisha
                         AND IsActive = true
                         AND Alias != 'gwadmin'
                         ORDER BY UserRole.DeveloperName, DisplayedUsernameFormula__c];
      }

      lsUsrOtherGroup = new List<User>();
      mailToAddressList = new List<MailAddress>();
      mailCcAddressList = new List<MailAddress>();
      mailBccAddressList = new List<MailAddress>();

    }

    public void refreshOtherDepartment() {
system.debug('refreshOtherDepartment: ' + otherDepartmentCode);
      lsUsrOtherGroup = new List<User>();
      if (otherDepartmentCode != '') {

        List<String> lsShitenShisha = new List<String>();
        lsShitenShisha.add(otherDepartmentCode);
        if (otherDepartmentCode != auConstantCmn.ROLE_CODE_HONBU) {
          // Get the Id of the role
          Id currentOrdgId = NUll;
          For (UserRole ur : [SELECT Id FROM UserRole WHERE DeveloperName = :otherDepartmentCode]) {
            currentOrdgId = ur.Id;
          }

          // Get the list of the Shiten
          for (UserRole ur : [SELECT Id, DeveloperName FROM UserRole WHERE ParentRoleId = :currentOrdgId AND ParentRoleId != NULL]) {
            lsShitenShisha.add(ur.DeveloperName);
          }

        }

        if (otherDepartmentCode != auConstantCmn.ROLE_CODE_HONBU) {
          lsUsrOtherGroup = [SELECT Id, Name, Email, TechnicalAlwaysFalse__c, DisplayedUsernameFormula__c, KDDIEmployeeId__c
                             FROM User
                             WHERE UserRole.DeveloperName IN :lsShitenShisha
                             AND IsActive = true
                             ORDER BY Profile.Name, UserRole.DeveloperName, DisplayedUsernameFormula__c];
        } else {
          lsUsrOtherGroup = [SELECT Id, Name, Email, TechnicalAlwaysFalse__c, DisplayedUsernameFormula__c, KDDIEmployeeId__c
                             FROM User
                             WHERE UserRole.DeveloperName IN :lsShitenShisha
                             AND IsActive = true
                             AND Alias != 'gwadmin'
                             ORDER BY UserRole.DeveloperName, DisplayedUsernameFormula__c];
        }
      }
    }


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
     * ユーザ事に保存されたパターンを取得し、アドレスを設定する
     **/
    public void acquisition(){
        system.debug(patternData);
        // パターンを保存した１番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_1.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory1__c, false);
        }
        // パターンを保存した２番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_2.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory2__c, false);
        }
        // パターンを保存した３番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_3.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory3__c, false);
        }
        // パターンを保存した４番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_4.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory4__c, false);
        }
        // パターンを保存した５番目の選択リストが選択された場合
        if (DISPLAY_PATTERN_5.equals(patternData)) {
            settingTextArea(myUser.MailAddressMemory5__c, false);
        }

    }

    /**
     * 保持した文字列をテキストエリアに変換に各項目にセットする
     * @param memoryStr　保持したアドレス群
     **/
        public void settingTextArea (String memoryStr, boolean isConfirmation) {
            system.debug(memoryStr);
            if (!isConfirmation) {
              mailToAddressList = new List<MailAddress>();
              mailCcAddressList = new List<MailAddress>();
              mailBccAddressList = new List<MailAddress>();
            } else {
              mailToAddressListConfirm = new List<MailAddress>();
              mailCcAddressListConfirm = new List<MailAddress>();
              mailBccAddressListConfirm = new List<MailAddress>();
            }

        //[TO][CC][BCC]の合計数１３以下の場合、空なためクリアした状態上書き
        if (memoryStr!=null) {
            // [TO]を含めたtoアドレス末尾までの件数
            Integer toCount = memoryStr.indexOf('[TO]');
            // [TO]を含めたtoアドレス末尾までの件数
            Integer ccCount = memoryStr.indexOf('[CC]');
            // [TO][CC]を含めたtoアドレス+CCアドレス末尾までの件数
            Integer bccCount = memoryStr.indexOf('[BCC]');

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
                      if (!isConfirmation) {
                        mailToAddressList.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                      } else {
                        mailToAddressListConfirm.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                      }
                    //アドレス欄の先頭に手入力の文字がない場合
                    } else {
                      if (fullUserMap.containsKey(to)) {
                        // Inactive users are not in the map and are ignored
                        String nameEmailStr = fullUserMap.get(to);
                        String[] nameEmailList = nameEmailStr.split(',',0);
                        if (!isConfirmation) {
                          mailToAddressList.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                        } else {
                          mailToAddressListConfirm.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                        }
                      }
                    }
                }
            } else {
              if (!isConfirmation) {
                mailToAddressList = new List<MailAddress>();
              } else {
                mailToAddressListConfirm = new List<MailAddress>();
              }
            }
            // CCアドレス欄に入力があった場合
            if (memoryCCStr.length() > 0) {
                for (String to : inputCcList) {
                    //アドレス欄の先頭に手入力の文字がある場合
                    if (to.startsWith('手入力')) {
                      if (!isConfirmation) {
                        mailCcAddressList.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                      } else {
                        mailCcAddressListConfirm.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                      }
                    //アドレス欄の先頭に手入力の文字がない場合
                    } else {
                      if (fullUserMap.containsKey(to)) {
                        // Inactive users are not in the map and are ignored
                        String nameEmailStr = fullUserMap.get(to);
                        String[] nameEmailList = nameEmailStr.split(',',0);
                        if (!isConfirmation) {
                          mailCcAddressList.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                        } else {
                          mailCcAddressListConfirm.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                        }
                      }
                    }
                }
            } else {
              if (!isConfirmation) {
                mailCcAddressList = new List<MailAddress>();
              } else {
                mailCcAddressListConfirm = new List<MailAddress>();
              }
            }
            // BCCアドレス欄に入力があった場合
            if (memoryBCCStr.length() > 0) {
                for (String to : inputBccList) {
                    //アドレス欄の先頭に手入力の文字がある場合
                    if (to.startsWith('手入力')) {
                      if (!isConfirmation) {
                        mailBccAddressList.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                      } else {
                        mailBccAddressListConfirm.add(new MailAddress(null,'手入力',to.substring(3, to.length())));
                      }
                    //アドレス欄の先頭に手入力の文字がない場合
                    } else {
                      if (fullUserMap.containsKey(to)) {
                        // Inactive users are not in the map and are ignored
                        String nameEmailStr = fullUserMap.get(to);
                        String[] nameEmailList = nameEmailStr.split(',',0);
                        if (!isConfirmation) {
                          mailBccAddressList.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                        } else {
                          mailBccAddressListConfirm.add(new MailAddress(to,nameEmailList[0],nameEmailList[1]));
                        }
                      }
                    }
                }
            } else {
              if (!isConfirmation) {
                mailBccAddressList = new List<MailAddress>();
              } else {
                mailBccAddressListConfirm = new List<MailAddress>();
              }
            }

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

    public PageReference redirectIfNecessaryDesktop(){

        if (isIPhone) {
            return Page.auScheduleMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        if (!isIPhone) {
            return Page.auSchedule.setRedirect(true);
        }

        return null;
    }

    public void gotoPreviousMonth() {
        dCurrentMonth = dCurrentMonth.addMonths(-1);
        refreshMonth();
    }

    public void gotoNextMonth() {
        dCurrentMonth = dCurrentMonth.addMonths(1);
        refreshMonth();
    }

    public String getCurrentMonthLabel() {
        return '' + dCurrentMonth.year() + '年' + dCurrentMonth.month() + '月';
    }

    private void refreshMonth() {

        lsDaysOfMonth = new List<List<clsDay>>();
        clsDayCurrentDay = new List<clsEventCurrentDay>();

        // Get the Sunday preceding (or equaling) the 1st day of the month
        Date dTmp = dCurrentMonth.addDays(math.mod(dCurrentMonth.daysBetween(Date.newInstance(1900, 1, 7)), 7));

        List<Event> lsEventsMonth = getEventSearch(false);

        for (integer i=0; i<6; i++) {

            List<clsDay> lsDaysOfWeek = new List<clsDay>();
            for (integer j=0; j<7; j++) {
                clsDay dayTmp = new clsDay();
                if (dTmp.month() == dCurrentMonth.month()) {
                    dayTmp.dDate = dTmp;
                    if (dTmp == Date.today()) {
                        dayTmp.isToday = true;
                    }
                    if (j==0) {
                        dayTmp.isSunday = true;
                    } else if (j==6) {
                        dayTmp.isSaturday = true;
                    }

                    // Add the Events
                    for (Event evt : lsEventsMonth) {
                        if (evt.ActivityDate == dTmp) {
                          clsEvent evtTmp = new clsEvent(evt, dayTmp.lsEvt.size());
                          dayTmp.lsEvt.add(evtTmp);
                          if (evt.ActivityReportSent__c) {
                            dayTmp.isSent = true;
                          }
                        }
                    }

                } else {
                    dayTmp.isBlank = true;
                }

                lsDaysOfWeek.add(dayTmp);
                dTmp = dTmp.addDays(1);
            }
            lsDaysOfMonth.add(lsDaysOfWeek);
        }


    }

    public void showDetailWithCreateEvent() {

system.debug('dCurrentDay :' + dCurrentDay);
system.debug('createEventParam1 :' + createEventParam1);
system.debug('createEventParam2 :' + createEventParam2);

        if (dCurrentDay == NULL) return; // Previous event has still not finished

        Event newEvt = new Event();

        Integer startHr = Integer.valueOf(createEventParam1.substring(0, 2));
        Integer startMn = Integer.valueOf(createEventParam1.substring(3));
        Integer endHr = Integer.valueOf(createEventParam2.substring(0, 2));
        Integer endMn = Integer.valueOf(createEventParam2.substring(3));

        if (startHr == endHr && startMn == endMn) {
          endHr++;
        }

        newEvt.StartDateTime = Datetime.newInstance(dCurrentDay.year(), dCurrentDay.month(), dCurrentDay.day(),
                                                    startHr, startMn, 0);
        newEvt.EndDateTime = Datetime.newInstance(dCurrentDay.year(), dCurrentDay.month(), dCurrentDay.day(),
                                                  endHr, endMn, 0);
        newEvt.Description = '';

        clsDayCurrentDay.add(new clsEventCurrentDay(newEvt, 999));

        clsDayCurrentDay.sort();
        Integer iSortNo = 0;
        for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
            clsEvt.sortNo = iSortNo++;
        }

        calculPositionEvent();

    }

    public void dummyAction() {
    }

    public void showDay() {
      system.debug('showDay: ' + showDayParam1);
      dCurrentDay = Date.newInstance(dCurrentMonth.year(), dCurrentMonth.month(), Integer.valueOf(showDayParam1));
      isCurrentDaySent = false;

      clsDayCurrentDay = new List<clsEventCurrentDay>();

      for (Event evt : getEventSearch(true)) {
        clsEventCurrentDay evtTmp = new clsEventCurrentDay(evt, clsDayCurrentDay.size());
        if (evt.ActivityReportSent__c) {
          isCurrentDaySent = true;
        }
        clsDayCurrentDay.add(evtTmp);
      }

      for (List<clsDay> lsClsDayTmp : lsDaysOfMonth) {
        for (clsDay clsDayTmp : lsClsDayTmp) {
          if ('' + clsDayTmp.getDayDate() == showDayParam1) {
            system.debug('showDay FOUND');
            clsDayTmp.isSelected = true;
//          clsDayCurrentDay = clsDayTmp;
          } else {
            clsDayTmp.isSelected = false;
          }
        }
      }
      calculPositionEvent();

    }

    public void calculPositionEvent() {


      // Calcul the position of each event

      // Step 1. Reinitialize
      for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
        clsEvt.eventGroupNo = 0;
        clsEvt.simultaneousEvent = 0;
        clsEvt.simultaneousEventGroup = 0;
        clsEvt.positionInsideGroup = 0;
      }

      // Step 1. Group independant events together
      integer countAllDayEvent = 0;

      // Step 1a. Count All Days Events (They should appear in 1st but due to recurring events, it is not always the case)
      // For recurring events where the GMT time is the day before, the Activity Date is the day before (it should normally be the day of the event)
      for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
        if (clsEvt.evt.IsAllDayEvent && !clsEvt.isDeleted) {
          // If there is an All Day event, then there is only 1 group
          countAllDayEvent++;
        }
      }

      // Step 1b. Set eventGroupNo when there is all days events
      if (countAllDayEvent > 0) {
        for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
          clsEvt.eventGroupNo = 1;
        }
      }

      Integer iMaxGroupNo = 1;
      if (countAllDayEvent == 0) {
        Integer currentGroupNo = 0;
        Datetime maxEndDatetime = NULL;
        for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
          if (!clsEvt.isDeleted) {
            if (currentGroupNo == 0 || clsEvt.evt.StartDateTime >= maxEndDatetime) {
              currentGroupNo++;
              maxEndDatetime = NULL;
            }
            clsEvt.eventGroupNo = currentGroupNo;
            if (maxEndDatetime == NULL || clsEvt.getEndDateTimeDisplayed() > maxEndDatetime) {
              maxEndDatetime = clsEvt.getEndDateTimeDisplayed();
            }
          }
        }
        iMaxGroupNo = currentGroupNo;
      }

      // Step 2. Calcul number of simulateous events for each event
      for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
        if (!clsEvt.evt.IsAllDayEvent && !clsEvt.isDeleted) {
          clsEvt.simultaneousEvent = getNbSimultaneousEvent(clsEvt);
        }
      }

      // Step 3. Calcul the max number of simulateous events for each group
      Map<integer, integer> mpGroupCount = new Map<integer, integer>();
      for (integer iGrp = 1; iGrp <= iMaxGroupNo; iGrp++) {
        mpGroupCount.put(iGrp, 0);
      }
      for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
        if (!clsEvt.isDeleted) {
          if (clsEvt.simultaneousEvent > mpGroupCount.get(clsEvt.eventGroupNo)) {
            mpGroupCount.put(clsEvt.eventGroupNo, clsEvt.simultaneousEvent);
          }
        }
      }
      for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
        if (!clsEvt.isDeleted) {
          clsEvt.simultaneousEventGroup = mpGroupCount.get(clsEvt.eventGroupNo) + countAllDayEvent;
        }
      }

      // Step 4. Calcul the index of the column for each event
      for (clsEventCurrentDay currentEvt : clsDayCurrentDay) {
        if (!currentEvt.isDeleted) {

          boolean fNotUsedFound = false;
          Integer iIdx = 0;

          while (!fNotUsedFound) {
            iIdx++;
            fNotUsedFound = true;
            for (clsEventCurrentDay clsEvtLoop : clsDayCurrentDay) {
              if (clsEvtLoop.eventGroupNo == currentEvt.eventGroupNo && clsEvtLoop.positionInsideGroup == iIdx) {
                if (clsEvtLoop.evt.IsAllDayEvent || currentEvt.evt.IsAllDayEvent || clsEvtLoop.getEndDateTimeDisplayed() > currentEvt.evt.StartDateTime) {
                  fNotUsedFound = false;
                  break;
                }
              }
            }
          }

          currentEvt.positionInsideGroup = iIdx;
        }

      }

    }

    public integer getNbSimultaneousEvent(clsEventCurrentDay clsEvt) {
      // 1. Create a map with each minute from StartDateTime (included) to EndDateTimeDisplayed (excluded)
      Map<Datetime, integer> mpCount = new Map<Datetime, integer>();
      Datetime dCurrentDatetime = clsEvt.evt.StartDateTime;
      while (dCurrentDatetime < clsEvt.getEndDateTimeDisplayed()) {
        if (dCurrentDatetime.hour() >= 6) { // We count only for the period 6:00 ~ 23:59
          mpCount.put(dCurrentDatetime, 0);
        }
        dCurrentDatetime = dCurrentDatetime.addMinutes(1);
      }

      for (clsEventCurrentDay clsEvtLoop : clsDayCurrentDay) {
        if (!clsEvtLoop.evt.IsAllDayEvent &&
            !clsEvtLoop.isDeleted &&
            clsEvtLoop.evt.StartDateTime < clsEvt.getEndDateTimeDisplayed() &&
            clsEvt.evt.StartDateTime < clsEvtLoop.getEndDateTimeDisplayed()) {
          Datetime dCurrentDatetimeLoop = clsEvtLoop.evt.StartDateTime;
          while (dCurrentDatetimeLoop < clsEvtLoop.getEndDateTimeDisplayed()) {
            if (mpCount.containsKey(dCurrentDatetimeLoop)) {
              mpCount.put(dCurrentDatetimeLoop, mpCount.get(dCurrentDatetimeLoop) + 1);
            }
            dCurrentDatetimeLoop = dCurrentDatetimeLoop.addMinutes(1);
          }
        }
      }

      integer iMax = 0;
      for (Datetime key : mpCount.keySet()) {
        if (mpCount.get(key) > iMax) {
          iMax = mpCount.get(key);
        }
      }
      return iMax;
    }

    public void doDeleteCurrentEvent() {
system.debug('doDeleteCurrentEvent - Search for sortNo ' + deleteEventParam1);

        for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
system.debug('doDeleteCurrentEvent - Current sortNo ' + clsEvt.sortNo + ', id ' + clsEvt.evt.Id);

            if (clsEvt.sortNo == Integer.valueOf(deleteEventParam1) && !clsEvt.isDeleted) {
system.debug('doDeleteCurrentEvent - Found');
                clsEvt.isDeleted = true;
            }
        }

        calculPositionEvent();

    }

    public void confirmEmail() {

system.debug('confirmEmail');
      resultTextArea = '';
      mailTitle = dCurrentDay.month() + '/' + dCurrentDay.day() + ' ' +
                  MAIL_SUBJECT_TEMP + ' ' +
                  (myUser.Department == NULL ? '' : myUser.Department + ' ') +
                  myUser.Name;

      // Save the data
      saveDayEvents(false);
      if (messageError != '') {
        // Stop here if there is any error
        return;
      }

      // Update mailToAddressListConfirm...
      if (DISPLAY_PATTERN_1.equals(patternDataToSend)) {
          settingTextArea(myUser.MailAddressMemory1__c, true);
      }
      if (DISPLAY_PATTERN_2.equals(patternDataToSend)) {
          settingTextArea(myUser.MailAddressMemory2__c, true);
      }
      if (DISPLAY_PATTERN_3.equals(patternDataToSend)) {
          settingTextArea(myUser.MailAddressMemory3__c, true);
      }
      if (DISPLAY_PATTERN_4.equals(patternDataToSend)) {
          settingTextArea(myUser.MailAddressMemory4__c, true);
      }
      if (DISPLAY_PATTERN_5.equals(patternDataToSend)) {
          settingTextArea(myUser.MailAddressMemory5__c, true);
      }

      // Create the body of the email
      for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
        if (!clsEvt.isDeleted && clsEvt.isSelected) {
          if (resultTextArea.length() != 0) {
            resultTextArea += '\n';
          }
          //開始日時　終了日時
          if (!clsEvt.evt.IsAllDayEvent) {
            resultTextArea += clsEvt.evt.StartDateTime.format('yyyy-MM-dd HH:mm') + ' ～ ' + clsEvt.evt.EndDateTime.format('yyyy-MM-dd HH:mm') + '\n';
          } else {
            resultTextArea += clsEvt.evt.StartDateTime.format('yyyy-MM-dd') + ' ～ ' + clsEvt.evt.EndDateTime.format('yyyy-MM-dd') + '\n';
          }

          //選択カテゴリ
          resultTextArea += (clsEvt.evt.Category__c == NULL ? '' : ('【カテゴリ】' + clsEvt.evt.Category__c)) + '\n';

          //タイトル
          resultTextArea += (clsEvt.evt.Subject == NULL ? '' : ('【件名】' + clsEvt.evt.Subject)) + '\n';

          //本文
          if (clsEvt.evt.Description != NULL && clsEvt.evt.Description.trim().length() > 0) {
            resultTextArea += clsEvt.evt.Description + '\n';
          }

          //代理店名
          String accName = '';
          if(clsEvt.evt.Account__c != null){
            Account acc = [SELECT Name FROM Account WHERE Id = :clsEvt.evt.Account__c LIMIT 1];
            accName = '【代理店/店舗】' + acc.Name;
          }
          resultTextArea += (accName + '\n');

          if (clsEvt.evt.AuNewMNP__c != NULL || clsEvt.evt.AuNewTablet__c != NULL || clsEvt.evt.AuNewRooter__c != NULL || clsEvt.evt.AuModelChange__c != NULL || clsEvt.evt.AuTotal__c != NULL) {
            resultTextArea += '＜au＞' + '\n';
          }
          if (clsEvt.evt.AuNewMNP__c != NULL) {
            resultTextArea += '  新規：合計 - ' + clsEvt.evt.AuNewMNP__c + '件' + '\n';
          }
          if (clsEvt.evt.AuNewTablet__c != NULL) {
            resultTextArea += '  新規：ハンドセット - ' + clsEvt.evt.AuNewTablet__c + '件' + '\n';
          }
          if (clsEvt.evt.AuNewRooter__c != NULL) {
            resultTextArea += '  新規：MNP - ' + clsEvt.evt.AuNewRooter__c + '件' + '\n';
          }
          if (clsEvt.evt.AuModelChange__c != NULL) {
            resultTextArea += '  機変 - ' + clsEvt.evt.AuModelChange__c + '件' + '\n';
          }
          if (clsEvt.evt.AuTotal__c != NULL) {
            resultTextArea += '  総販 - ' + clsEvt.evt.AuTotal__c + '件' + '\n';
          }

          if (clsEvt.evt.BBCHikari__c != NULL || clsEvt.evt.BBCCableTosu__c != NULL) {
            resultTextArea += '＜BBC＞' + '\n';
          }
          if (clsEvt.evt.BBCHikari__c != NULL) {
            resultTextArea += '  BBC：ひかり - ' + clsEvt.evt.BBCHikari__c + '件' + '\n';
          }
          if (clsEvt.evt.BBCCableTosu__c != NULL) {
            resultTextArea += '  BBC：ケーブルトス - ' + clsEvt.evt.BBCCableTosu__c + '件' + '\n';
          }

          if (clsEvt.evt.UQ_2__c != NULL || clsEvt.evt.UQ_3__c != NULL) {
            resultTextArea += '＜UQモバイル成約実績 = 新規加入+sim単体販売実績＞　　※UQモバイル取扱い店のみご報告をお願い致します。' + '\n';
          }
          if (clsEvt.evt.UQ_2__c != NULL) {
            resultTextArea += '  UQモバイル：auスタッフ直取 - ' + clsEvt.evt.UQ_2__c + '件' + '\n';
          }
          if (clsEvt.evt.UQ_3__c != NULL) {
            resultTextArea += '  UQモバイル：UQ振り成約実績 - ' + clsEvt.evt.UQ_3__c + '件' + '\n';
          }

          if (clsEvt.evt.auDenki__c != NULL || clsEvt.evt.WALLET_Market__c != NULL || clsEvt.evt.WaterServer__c != NULL) {
            resultTextArea += '＜ライフデザイン関連商材＞　　※WALLET Market商材については、取扱い店のみご報告をお願い致します。' + '\n';
          }
          if (clsEvt.evt.auDenki__c != NULL) {
            resultTextArea += '  auでんき - ' + clsEvt.evt.auDenki__c + '件' + '\n';
          }
          if (clsEvt.evt.WALLET_Market__c != NULL) {
            resultTextArea += '  WALLET Market - ' + clsEvt.evt.WALLET_Market__c + '円' + '\n';
          }
          if (clsEvt.evt.WaterServer__c != NULL) {
            resultTextArea += '  ウォーターサーバー - ' + clsEvt.evt.WaterServer__c + '件' + '\n';
          }
          
          if(clsEvt.evt.Category__c == '代理店商談'){
	          if (clsEvt.evt.NormalMeeting__c != NULL) {
	          	if(clsEvt.evt.NormalMeeting__c == true){
	          		resultTextArea += '【通常商談】チェックあり' + '\n';
	          	}else{
	          		resultTextArea += '【通常商談】チェックなし' + '\n';
	          	}
	          }
	          if (clsEvt.evt.CCPMeeting__c != NULL) {
	          	if(clsEvt.evt.CCPMeeting__c == true){
	          		resultTextArea += '【CCP商談】チェックあり' + '\n';
	          	}else{
	          		resultTextArea += '【CCP商談】チェックなし' + '\n';
	          	}
	          }
          }
          
          if(clsEvt.evt.Category__c == '代理店商談' || clsEvt.evt.Category__c == '拠点フォロー') {
	          if (clsEvt.auActivity.EventPurpose__c != NULL && clsEvt.auActivity.EventPurpose__c != '') {
	            resultTextArea += '【目的】' + clsEvt.auActivity.EventPurpose__c + '\n';
	          }
	          if (clsEvt.auActivity.EventInterviewer__c != NULL && clsEvt.auActivity.EventInterviewer__c != '') {
	            resultTextArea += '【面談者】' + clsEvt.auActivity.EventInterviewer__c + '\n';
	          }
	          if (clsEvt.auActivity.EventRemarks__c != NULL && clsEvt.auActivity.EventRemarks__c != '') {
	            resultTextArea += '【備考】' + clsEvt.auActivity.EventRemarks__c + '\n';
	          }          
          }

          if(clsEvt.evt.Category__c == '代理店商談'){
	          if (clsEvt.evt.ReflectOnCCP__c != NULL) {
	          	if(clsEvt.evt.ReflectOnCCP__c == true){
	          		resultTextArea += '【CCP+に反映】チェックあり' + '\n';
	          	}else{
	          		resultTextArea += '【CCP+に反映】チェックなし' + '\n';
	          	}
	          }
	          if (clsEvt.auActivity.EventOrganization__c != NULL && clsEvt.auActivity.EventOrganization__c != '') {
	            resultTextArea += '  【代理店の組織・体制】' + clsEvt.auActivity.EventOrganization__c + '\n';
	          }
	          if (clsEvt.auActivity.EventManagedCustomersCount__c != NULL && clsEvt.auActivity.EventManagedCustomersCount__c != '') {
	            resultTextArea += '  【管理顧客数】' + clsEvt.auActivity.EventManagedCustomersCount__c + '\n';
	          }
	          if (clsEvt.auActivity.EventStaff__c != NULL && clsEvt.auActivity.EventStaff__c != '') {
	            resultTextArea += '  【スタッフ数】' + clsEvt.auActivity.EventStaff__c + '\n';
	          }
	          if (clsEvt.auActivity.EventQualificationRate__c != NULL && clsEvt.auActivity.EventQualificationRate__c != '') {
	            resultTextArea += '  【資格保有率】' + clsEvt.auActivity.EventQualificationRate__c + '\n';
	          }
	          if (clsEvt.auActivity.EventTurnover__c != NULL && clsEvt.auActivity.EventTurnover__c != '') {
	            resultTextArea += '  【離職率】' + clsEvt.auActivity.EventTurnover__c + '\n';
	          }
	          if (clsEvt.auActivity.EventRegularEmployeesPercent__c != NULL && clsEvt.auActivity.EventRegularEmployeesPercent__c != '') {
	            resultTextArea += '  【正社員比率】' + clsEvt.auActivity.EventRegularEmployeesPercent__c + '\n';
	          }
	          if (clsEvt.auActivity.EventStaffES__c != NULL && clsEvt.auActivity.EventStaffES__c != '') {
	            resultTextArea += '  【スタッフＥＳ】' + clsEvt.auActivity.EventStaffES__c + '\n';
	          }
	          if (clsEvt.auActivity.EventManagementAbilityEvaluation__c != NULL && clsEvt.auActivity.EventManagementAbilityEvaluation__c != '') {
	            resultTextArea += '  【運営法人運営力評価】' + clsEvt.auActivity.EventManagementAbilityEvaluation__c + '\n';
	          }
	          if (clsEvt.auActivity.EventauComprehensiveIndex__c != NULL && clsEvt.auActivity.EventauComprehensiveIndex__c != '') {
	            resultTextArea += '  【auショップ総合指標】' + clsEvt.auActivity.EventauComprehensiveIndex__c + '\n';
	          }
	          if (clsEvt.auActivity.EventNPS__c != NULL && clsEvt.auActivity.EventNPS__c != '') {
	            resultTextArea += '  【NPS】' + clsEvt.auActivity.EventNPS__c + '\n';
	          }
	          if (clsEvt.auActivity.EventCorpPhilosophyVision__c != NULL && clsEvt.auActivity.EventCorpPhilosophyVision__c != '') {
	            resultTextArea += '  【企業理念・ビジョン】' + clsEvt.auActivity.EventCorpPhilosophyVision__c + '\n';
	          }
	          if (clsEvt.auActivity.EventBusinessPlan__c != NULL && clsEvt.auActivity.EventBusinessPlan__c != '') {
	            resultTextArea += '  【事業戦略・事業計画】' + clsEvt.auActivity.EventBusinessPlan__c + '\n';
	          }
	          if (clsEvt.auActivity.EventStoreStrategy__c != NULL && clsEvt.auActivity.EventStoreStrategy__c != '') {
	            resultTextArea += '  【店舗戦略】' + clsEvt.auActivity.EventStoreStrategy__c + '\n';
	          }
	          if (clsEvt.auActivity.EventPolicyPlanning__c != NULL && clsEvt.auActivity.EventPolicyPlanning__c != '') {
	            resultTextArea += '  【計画・施策立案】' + clsEvt.auActivity.EventPolicyPlanning__c + '\n';
	          }
	          if (clsEvt.auActivity.EventProgressManagementReporting__c != NULL && clsEvt.auActivity.EventProgressManagementReporting__c != '') {
	            resultTextArea += '  【進捗管理・報告】' + clsEvt.auActivity.EventProgressManagementReporting__c + '\n';
	          }
	          if (clsEvt.auActivity.EventPersonnelSystem__c != NULL && clsEvt.auActivity.EventPersonnelSystem__c != '') {
	            resultTextArea += '  【人員体制】' + clsEvt.auActivity.EventPersonnelSystem__c + '\n';
	          }
	          if (clsEvt.auActivity.EventDecisionRule__c != NULL && clsEvt.auActivity.EventDecisionRule__c != '') {
	            resultTextArea += '  【意志決定ルール】' + clsEvt.auActivity.EventDecisionRule__c + '\n';
	          }
	          if (clsEvt.auActivity.EventEvaluation__c != NULL && clsEvt.auActivity.EventEvaluation__c != '') {
	            resultTextArea += '  【評価】' + clsEvt.auActivity.EventEvaluation__c + '\n';
	          }
	          if (clsEvt.auActivity.EventRecruitment__c != NULL && clsEvt.auActivity.EventRecruitment__c != '') {
	            resultTextArea += '  【採用】' + clsEvt.auActivity.EventRecruitment__c + '\n';
	          }
	          if (clsEvt.auActivity.EventCultivationEstablishment__c != NULL && clsEvt.auActivity.EventCultivationEstablishment__c != '') {
	            resultTextArea += '  【育成・定着】' + clsEvt.auActivity.EventCultivationEstablishment__c + '\n';
	          }
	          if (clsEvt.auActivity.EventCommunicationPlace__c != NULL && clsEvt.auActivity.EventCommunicationPlace__c != '') {
	            resultTextArea += '  【コミュニケーションの場】' + clsEvt.auActivity.EventCommunicationPlace__c + '\n';
	          }
          }

          
          if (clsEvt.evt.ContentDocumentLinks != NULL && clsEvt.evt.ContentDocumentLinks.size() > 0) {
            for (ContentDocumentLink cdl : clsEvt.evt.ContentDocumentLinks) {
              if (mpContentVersion.containsKey(cdl.ContentDocumentId)) {
                resultTextArea += '□ ' + auCommunityCustomSettings__c.getOrgDefaults().DownloadFileUrl__c + mpContentVersion.get(cdl.ContentDocumentId) + '\n';
              }
            }
          }

          if (clsEvt.evt.Attachments != NULL && clsEvt.evt.Attachments.size() > 0) {
            for (Attachment att : clsEvt.evt.Attachments) {
              resultTextArea += '□ ' + auCommunityCustomSettings__c.getOrgDefaults().DownloadAttachUrl__c + att.Id + '\n';
            }
          }



        }
      }


    }

    public void saveDayEventsWithRefresh() {
      saveDayEvents(true);
    }

    public void saveDayEvents(boolean withRefresh) {

        messageError = '';

        try {

            List<Event> lsEvtToUpsert = new List<Event>();
            List<Event> lsEvtToDelete = new List<Event>();
            List<auActivityRelated__c> lsEvtRelatedToUpsert = new List<auActivityRelated__c>();

            for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
system.debug('saveDayEvents - isDeleted:' + clsEvt.isDeleted);
system.debug('saveDayEvents - Id:' + clsEvt.evt.Id);

                if (clsEvt.isDeleted) {
                    // Event deleted
                    if (clsEvt.evt.Id != NULL) {
                        // We only care about events already created in the DB
                        lsEvtToDelete.add(clsEvt.evt);
                    }
                } else {
                    // Event created or updated
                    Event evt = clsEvt.evt;
                    system.debug('saveDayEvents->evt: ' + evt);
                    system.debug('saveDayEvents->isCopyToCCP: ' + isCopyToCCP);
                    if(isCopyToCCP){
                      evt.ConfirmCopyToCCP__c = true;
                    }
                    
                    evt.Subject = clsEvt.evtTitle;

                    evt.Description = clsEvt.description;
                    if (!evt.IsAllDayEvent) {

                        List<String> partsStart = clsEvt.startTime.split(':');
                        if (partsStart.size() != 2) {
                            messageError = '開始時間を入力してください。';
                            return;
                        }

                        List<String> partsEnd = clsEvt.endTime.split(':');
                        if (partsEnd.size() != 2) {
                            messageError = '終了時間を入力してください。';
                            return;
                        }

                        evt.StartDateTime = Datetime.newInstance(dCurrentDay.year(), dCurrentDay.month(), dCurrentDay.day(),
                                                                 Integer.valueOf(partsStart[0]), Integer.valueOf(partsStart[1]), 0);
                        evt.EndDateTime = Datetime.newInstance(dCurrentDay.year(), dCurrentDay.month(), dCurrentDay.day(),
                                                               Integer.valueOf(partsEnd[0]), Integer.valueOf(partsEnd[1]), 0);

                        evt.DurationInMinutes = 60 * (Integer.valueOf(partsEnd[0]) - Integer.valueOf(partsStart[0])) + (Integer.valueOf(partsEnd[1]) - Integer.valueOf(partsStart[1]));

                        if (evt.EndDateTime < evt.StartDateTime) {
                          evt.EndDateTime = evt.EndDateTime.addDays(1);
                          evt.DurationInMinutes += 60 * 24;
                        }
                    }

                    system.debug('categoryClsNm:' + clsEvt.categoryClsNm);
                    if (clsEvt.categoryClsNm == 'category1') {
                        evt.Type__c = '社外';
                    } else if (clsEvt.categoryClsNm == 'category2') {
                        evt.Type__c = '社内';
                    } else if (clsEvt.categoryClsNm == 'category3') {
                        evt.Type__c = 'その他';
                    } else {
                        evt.Type__c = NULL;
                        // messageError = 'カテゴリを入力してください。';
                        // return;
                    }

                    evt.Category__c = clsEvt.categoryClsNm != 'category3' && clsEvt.categoryClsNm != 'category0' ? clsEvt.categoryNm : NULL;

                    if (evt.Account__c == NULL && evt.WhatId != NULL && evt.WhatId.getsObjectType() == Account.sObjectType) {
                      evt.WhatId = NULL;
                    } else if (evt.Account__c != NULL) {
                      evt.WhatId = evt.Account__c;
                    }
					
					if(evt.auActivityRelated__c == NULL){
						evt.auActivityRelated__c = clsEvt.auActivity.id;
					}
					lsEvtRelatedToUpsert.add(clsEvt.auActivity);
					
                    lsEvtToUpsert.add(evt);

                }
            }

system.debug('saveDayEvents - loop finished');

            if (withRefresh) {
              clsDayCurrentDay = new List<clsEventCurrentDay>();
              lsDaysOfMonth = new List<List<clsDay>>();
            }


            if (lsEvtToUpsert != NULL && lsEvtToUpsert.size() > 0) {
system.debug('saveDayEvents - before upsert');
                upsert lsEvtToUpsert;
system.debug('saveDayEvents - adter upsert');
            }
            if (lsEvtRelatedToUpsert != NULL && lsEvtRelatedToUpsert.size() > 0) {
system.debug('saveDayEventsRelated - before upsert');
                upsert lsEvtRelatedToUpsert;
system.debug('saveDayEventsRelated - after upsert');
            }
            if (lsEvtToDelete != NULL && lsEvtToDelete.size() > 0) {
system.debug('saveDayEvents - before delete');
                delete lsEvtToDelete;
system.debug('saveDayEvents - after delete');
            }
system.debug('saveDayEvents - before refresh');
            if (withRefresh) {
              refreshMonth();
              showDay();
            }
system.debug('saveDayEvents - after refresh');

        } catch (Exception e) {
system.debug('saveDayEvents - catch');
            messageError = 'エラーが発生しました。' + e.getMessage();
system.debug('messageError:' + messageError);
            return;
        }

    }


    /**
     * 入力条件から活動を取得する
     * @param Datetime sDate
     * @param Datetime eDate
     */
    private List<Event> getEventSearch(boolean isOnlyDay) {

        List<Event> evList = new List<Event>();
        String startDate = null;
        String endDate = null;
        String queryStr  = '';
        String selectStr = ' SELECT Id, Subject, Description, StartDateTime, EndDateTime, IsAllDayEvent, DurationInMinutes, ActivityDate, (SELECT Id, ContentDocumentId FROM ContentDocumentLinks), ' +
                           '        AuNewMNP__c, AuNewTablet__c, AuNewRooter__c, AuModelChange__c, AuTotal__c, BBCHikari__c, BBCCableTosu__c, UQ_2__c, UQ_3__c, auDenki__c, ' +
                           '        WALLET_Market__c, WaterServer__c, Type__c, Category__c, WhatId, Account__c, Account__r.Name, ActivityReportSent__c, IsPrivate, (SELECT id, Name, IsPrivate, OwnerId FROM Attachments), ' +
                           '        NormalMeeting__c, CCPMeeting__c, ReflectOnCCP__c, ' +
                           '        auActivityRelated__c, auActivityRelated__r.EventPurpose__c, auActivityRelated__r.EventInterviewer__c, auActivityRelated__r.EventRemarks__c, ' +
                           '        auActivityRelated__r.EventOrganization__c, auActivityRelated__r.EventManagedCustomersCount__c, auActivityRelated__r.EventStaff__c, auActivityRelated__r.EventQualificationRate__c, ' + 
                           '		auActivityRelated__r.EventTurnover__c, auActivityRelated__r.EventRegularEmployeesPercent__c, auActivityRelated__r.EventStaffES__c, auActivityRelated__r.EventManagementAbilityEvaluation__c, ' + 
                           '		auActivityRelated__r.EventauComprehensiveIndex__c, auActivityRelated__r.EventNPS__c, auActivityRelated__r.EventCorpPhilosophyVision__c, auActivityRelated__r.EventBusinessPlan__c, ' + 
                           '	 	auActivityRelated__r.EventStoreStrategy__c, auActivityRelated__r.EventPolicyPlanning__c, auActivityRelated__r.EventProgressManagementReporting__c, auActivityRelated__r.EventPersonnelSystem__c, ' + 
                           '		auActivityRelated__r.EventDecisionRule__c, auActivityRelated__r.EventEvaluation__c, auActivityRelated__r.EventRecruitment__c, auActivityRelated__r.EventCultivationEstablishment__c, ' + 
                           '		auActivityRelated__r.EventCommunicationPlace__c, ConfirmCopyToCCP__c';
        String fromStr   = ' FROM Event ';
        String whereStr  = ' WHERE ownerId = \'' + UserInfo.getUserId() + '\'' +
                           ' AND IsRecurrence = False' ;
        String orderStr  = ' ORDER BY ActivityDate, IsAllDayEvent desc, StartDateTime, EndDateTime DESC';

        // Note: for GMT-xx, this algorithm does not work for All Day events
        if (!isOnlyDay && dCurrentMonth != null) {
            Datetime sDateTime = Datetime.newInstance(dCurrentMonth.year(), dCurrentMonth.month(), dCurrentMonth.day());
            startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            whereStr += ' And StartDateTime >= ' + startDate;

            Date eDate = dCurrentMonth.addMonths(1);
            Datetime sEndTime = Datetime.newInstance(eDate.year(), eDate.month(), eDate.day());
            endDate = sEndTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            whereStr += ' And StartDateTime < ' + endDate;
        }

        if (isOnlyDay && dCurrentDay != null) {
            Datetime sDateTime = Datetime.newInstance(dCurrentDay.year(), dCurrentDay.month(), dCurrentDay.day());
            startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            whereStr += ' And StartDateTime >= ' + startDate;

            Date eDate = dCurrentDay.addDays(1);
            Datetime sEndTime = Datetime.newInstance(eDate.year(), eDate.month(), eDate.day());
            endDate = sEndTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            whereStr += ' And StartDateTime < ' + endDate;
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
          if (ev.WhatId != NULL && ev.WhatId.getsObjectType() == Account.sObjectType) {
            ev.Account__c = ev.WhatId;
          }

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

    public class clsDay{

        public Date dDate {get;set;}
        public boolean isSent {get;set;}
        public boolean isToday {get;set;}
        public boolean isSelected {get;set;}
        public boolean isBlank {get;set;}
        public boolean isSunday {get;set;}
        public boolean isSaturday {get;set;}
        public List<clsEvent> lsEvt {get;set;}

        public Integer getDayDate() {
          if (dDate == NULL) {
            return 0;
          }
          return dDate.day();
        }

/*
        public List<clsEvent> getLsEvtNotDeleted() {
            List<clsEvent> tmpLsEvt = new List<clsEvent>();
            for (clsEvent clsEvt : lsEvt) {
                if (!clsEvt.isDeleted) {
                    tmpLsEvt.add(clsEvt);
                }
            }
            return tmpLsEvt;
        }
*/

        public clsDay(){
            lsEvt = new List<clsEvent>();
        }

    }

    public class clsEvent {

        public Event evt {get;set;}
        public boolean isSelected {get;set;}
        public String startTime {get;set;}
        public String endTime {get;set;}
        public String evtTitle {get;set;}
        public String description {get;set;}
        public String categoryClsNm {get;set;}
        public String iconClsNm {get;set;}
        public boolean isDeleted {get;set;}
        public Integer sortNo {get;set;}

        public String getClsNmTimeStart() {
            if (evt.IsAllDayEvent) {
                return 'begin0600';
            }
            // TODO use startTime
            return 'begin' + ('0' + evt.StartDateTime.hour()).right(2) + ('0' + evt.StartDateTime.minute()).right(2);
        }
        public String getClsNmTimeEnd() {
            if (evt.IsAllDayEvent || evt.StartDateTime.day() != evt.EndDateTime.day()) {
                return 'end2400';
            }
            // TODO use endTime
            return 'end' + ('0' + evt.EndDateTime.hour()).right(2) + ('0' + evt.EndDateTime.minute()).right(2);
        }

        public clsEvent(Event paramEvt, Integer paramSortNo){

            this.evt = paramEvt;
            this.sortNo = paramSortNo;
            this.isDeleted = false;
            this.evtTitle = evt.Subject;
            this.description = evt.Description;
            if (!evt.IsAllDayEvent) {
                this.startTime = '' + evt.StartDateTime.hour() + ':' + ('0' + evt.StartDateTime.minute()).right(2);
                this.endTime = '' + evt.EndDateTime.hour() + ':' + ('0' + evt.EndDateTime.minute()).right(2);
            } else {
                this.startTime = '0:00';
                this.endTime = '24:00';
            }

            if (evt.Type__c == '社外') {
                categoryClsNm = 'category1';

                if (evt.Category__c == '拠点フォロー') {
                    iconClsNm = 'icon1';
                } else if (evt.Category__c == '代理店商談') {
                    iconClsNm = 'icon2';
                } else if (evt.Category__c == 'イベント対応') {
                    iconClsNm = 'icon3';
                } else if (evt.Category__c == '異業種連携') {
                    iconClsNm = 'icon4';
                } else if (evt.Category__c == '他キャリア視察') {
                    iconClsNm = 'icon5';
                } else if (evt.Category__c == 'サンプリング') {
                    iconClsNm = 'icon6';
                } else if (evt.Category__c == '移動') {
                    iconClsNm = 'icon7';
                } else if (evt.Category__c == '接待・接受') {
                    iconClsNm = 'icon8';
                } else if (evt.Category__c == '店長会議') {
                    iconClsNm = 'icon9';
                }

            } else if (evt.Type__c == '社内') {
                categoryClsNm = 'category2';

                if (evt.Category__c == '【old】店長会議') {
                    iconClsNm = 'icon1';
                } else if (evt.Category__c == '会議・ミーティング') {
                    iconClsNm = 'icon2';
                } else if (evt.Category__c == '社内行事') {
                    iconClsNm = 'icon3';
                } else if (evt.Category__c == '資料作成・事務処理') {
                    iconClsNm = 'icon4';
                } else if (evt.Category__c == 'ヒアリング・アンケート') {
                    iconClsNm = 'icon5';
                } else if (evt.Category__c == '架電') {
                    iconClsNm = 'icon6';
                } else if (evt.Category__c == '資格試験') {
                    iconClsNm = 'icon7';
                } else if (evt.Category__c == '店舗研修') {
                    iconClsNm = 'icon8';
                }

            } else if (evt.Type__c == 'その他') {
                categoryClsNm = 'category3';
                iconClsNm = 'icon1';
            } else {
                categoryClsNm = 'category0';
            }

        }


/*
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to clsEvent
            clsEvent compareToEvt = (clsEvent)compareTo;

            if (evt.IsAllDayEvent && !compareToEvt.evt.IsAllDayEvent) {
                return -1;
            } else if (!evt.IsAllDayEvent && compareToEvt.evt.IsAllDayEvent) {
                return 1;
            }

            List<String> partsStart = startTime.split(':');
            List<String> partsEnd = endTime.split(':');
            String strDate = ('0' + partsStart[0]).right(2) + ('0' + partsStart[1]).right(2) + ('0' + partsEnd[0]).right(2) + ('0' + partsEnd[1]).right(2);

            List<String> partsStartCompareTo = compareToEvt.startTime.split(':');
            List<String> partsEndCompareTo = compareToEvt.endTime.split(':');
            String strDateCompareTo = ('0' + partsStartCompareTo[0]).right(2) + ('0' + partsStartCompareTo[1]).right(2) + ('0' + partsEndCompareTo[0]).right(2) + ('0' + partsEndCompareTo[1]).right(2);

            if (strDate > strDateCompareTo) {
                return 1;
            } else if (strDate < strDateCompareTo) {
                return -1;
            }

            if (sortNo > compareToEvt.sortNo) {
                return 1;
            } else if (sortNo < compareToEvt.sortNo) {
                return -1;
            }

            return 0;
        }
*/

    }

    public class clsEventCurrentDay implements Comparable {

        public Event evt {get;set;}
        public auActivityRelated__c auActivity {get;set;}
        public boolean isSelected {get;set;}
        public String startTime {get;set;}
        public String endTime {get;set;}
        public String evtTitle {get;set;}
        public String description {get;set;}
        public String categoryClsNm {get;set;}
        public String categoryNm {get;set;}
        public Integer eventGroupNo {get;set;}
        public Integer simultaneousEvent {get;set;}
        public Integer simultaneousEventGroup {get;set;}
        public Integer positionInsideGroup {get;set;}

        private String iconClsNmVar = '';
        public String getIconClsNm() {
            return iconClsNmVar;
        }
        public void setIconClsNm(String param) {
            iconClsNmVar = param;
            if (categoryClsNm == 'category1') {
                if (iconClsNmVar == 'icon1') {
                    categoryNm = '拠点フォロー';
                } else if (iconClsNmVar == 'icon2') {
                    categoryNm = '代理店商談';
                } else if (iconClsNmVar == 'icon3') {
                    categoryNm = 'イベント対応';
                } else if (iconClsNmVar == 'icon4') {
                    categoryNm = '異業種連携';
                } else if (iconClsNmVar == 'icon5') {
                    categoryNm = '他キャリア視察';
                } else if (iconClsNmVar == 'icon6') {
                    categoryNm = 'サンプリング';
                } else if (iconClsNmVar == 'icon7') {
                    categoryNm = '移動';
                } else if (iconClsNmVar == 'icon8') {
                    categoryNm = '接待・接受';
                } else if (iconClsNmVar == 'icon9') {
                    categoryNm = '店長会議';
                }
            } else if (categoryClsNm == 'category2') {
                if (iconClsNmVar == 'icon1') {
                    categoryNm = '【old】店長会議';
                } else if (iconClsNmVar == 'icon2') {
                    categoryNm = '会議・ミーティング';
                } else if (iconClsNmVar == 'icon3') {
                    categoryNm = '社内行事';
                } else if (iconClsNmVar == 'icon4') {
                    categoryNm = '資料作成・事務処理';
                } else if (iconClsNmVar == 'icon5') {
                    categoryNm = 'ヒアリング・アンケート';
                } else if (iconClsNmVar == 'icon6') {
                    categoryNm = '架電';
                } else if (iconClsNmVar == 'icon7') {
                    categoryNm = '資格試験';
                } else if (iconClsNmVar == 'icon8') {
                    categoryNm = '店舗研修';
                }
            } else if (categoryClsNm == 'category3') {
                if (iconClsNmVar == 'icon1') {
                    categoryNm = 'その他';
                }
            }
        }

        public boolean isDeleted {get;set;}
        public Integer sortNo {get;set;}


        public Datetime getEndDateTimeDisplayed() {
            if (evt.IsAllDayEvent) {
                return NULL;
            }
            return evt.EndDateTime >= evt.StartDateTime.addMinutes(30) ? evt.EndDateTime : evt.StartDateTime.addMinutes(30);
        }

        public String getClsNmTimeStart() {
            if (evt.IsAllDayEvent) {
                return 'begin0600';
            }
            // TODO use startTime
            return 'begin' + ('0' + evt.StartDateTime.hour()).right(2) + ('0' + evt.StartDateTime.minute()).right(2);
        }
        public String getClsNmTimeEnd() {
            if (evt.IsAllDayEvent || evt.StartDateTime.day() != evt.EndDateTime.day()) {
                return 'end2400';
            }
            // TODO use endTime
            return 'end' + ('0' + getEndDateTimeDisplayed().hour()).right(2) + ('0' + getEndDateTimeDisplayed().minute()).right(2);
        }

        public String getClsNmDiv() {
            return 'div-' + (simultaneousEventGroup <= 8 ? simultaneousEventGroup : 8);
        }

        public String getClsNmCol() {
            return 'col-' + (positionInsideGroup <= 8 ? positionInsideGroup : 8);
        }

        public String getNmTimeFull() {

//          return getClsNmDiv() + ' ' + getClsNmCol();

            if (evt.IsAllDayEvent) {
                return '終日';
            }
            //return 'Grp ' + eventGroupNo + ' - ' + simultaneousEvent;
            return ('0' + evt.StartDateTime.hour()).right(2) + ':' + ('0' + evt.StartDateTime.minute()).right(2) + '-' +
                   ('0' + evt.EndDateTime.hour()).right(2) + ':' + ('0' + evt.EndDateTime.minute()).right(2);
        }

        public clsEventCurrentDay(Event paramEvt, Integer paramSortNo){

            this.evt = paramEvt;
            this.sortNo = paramSortNo;
            this.isDeleted = false;
            this.isSelected = true;
            this.evtTitle = evt.Subject;
            this.description = evt.Description;
            system.debug('evt.auActivityRelated__r: ' + evt.auActivityRelated__r);
            if(paramEvt.auActivityRelated__c == null){
            	auActivityRelated__c auRelated = new auActivityRelated__c();
            	insert auRelated;
            	this.auActivity = auRelated;
            	this.evt.auActivityRelated__c = auRelated.Id;
            	system.debug('new auActivityRelated__c');
            }else{
            	this.auActivity = [SELECT Id, EventPurpose__c, EventInterviewer__c, EventRemarks__c,
									EventOrganization__c, EventManagedCustomersCount__c, EventStaff__c,
									EventQualificationRate__c, EventTurnover__c, EventRegularEmployeesPercent__c,
									EventStaffES__c, EventManagementAbilityEvaluation__c, EventauComprehensiveIndex__c,
									EventNPS__c, EventCorpPhilosophyVision__c, EventBusinessPlan__c,
									EventStoreStrategy__c, EventPolicyPlanning__c, EventProgressManagementReporting__c,
									EventPersonnelSystem__c, EventDecisionRule__c, EventEvaluation__c,
									EventRecruitment__c, EventCultivationEstablishment__c, EventCommunicationPlace__c
            						 FROM auActivityRelated__c WHERE Id = :paramEvt.auActivityRelated__c];
            	system.debug('existing auActivityRelated__c');
            }
            system.debug('this.auActivity: ' + this.auActivity);
            
            if (!evt.IsAllDayEvent) {
                this.startTime = '' + evt.StartDateTime.hour() + ':' + ('0' + evt.StartDateTime.minute()).right(2);
                this.endTime = '' + evt.EndDateTime.hour() + ':' + ('0' + evt.EndDateTime.minute()).right(2);
            } else {
                this.startTime = '0:00';
                this.endTime = '24:00';
            }

            if (evt.Type__c == '社外') {
                categoryClsNm = 'category1';

                if (evt.Category__c == '拠点フォロー') {
                    this.setIconClsNm('icon1');
                } else if (evt.Category__c == '代理店商談') {
                    this.setIconClsNm('icon2');
                } else if (evt.Category__c == 'イベント対応') {
                    this.setIconClsNm('icon3');
                } else if (evt.Category__c == '異業種連携') {
                    this.setIconClsNm('icon4');
                } else if (evt.Category__c == '他キャリア視察') {
                    this.setIconClsNm('icon5');
                } else if (evt.Category__c == 'サンプリング') {
                    this.setIconClsNm('icon6');
                } else if (evt.Category__c == '移動') {
                    this.setIconClsNm('icon7');
                } else if (evt.Category__c == '接待・接受') {
                    this.setIconClsNm('icon8');
                } else if (evt.Category__c == '店長会議') {
                    this.setIconClsNm('icon9');
                }

            } else if (evt.Type__c == '社内') {
                categoryClsNm = 'category2';

                if (evt.Category__c == '【old】店長会議') {
                    this.setIconClsNm('icon1');
                } else if (evt.Category__c == '会議・ミーティング') {
                    this.setIconClsNm('icon2');
                } else if (evt.Category__c == '社内行事') {
                    this.setIconClsNm('icon3');
                } else if (evt.Category__c == '資料作成・事務処理') {
                    this.setIconClsNm('icon4');
                } else if (evt.Category__c == 'ヒアリング・アンケート') {
                    this.setIconClsNm('icon5');
                } else if (evt.Category__c == '架電') {
                    this.setIconClsNm('icon6');
                } else if (evt.Category__c == '資格試験') {
                    this.setIconClsNm('icon7');
                } else if (evt.Category__c == '店舗研修') {
                    this.setIconClsNm('icon8');
                }

            } else if (evt.Type__c == 'その他') {
                categoryClsNm = 'category3';
                this.setIconClsNm('icon1');
            } else {
                categoryClsNm = 'category0';
                categoryNm = '← カテゴリを選択してください。';
            }


        }

        // Comparison for sort method
        public Integer compareTo(Object compareTo) {
            // Cast argument to clsEvent
            clsEventCurrentDay compareToEvt = (clsEventCurrentDay)compareTo;

            if (evt.IsAllDayEvent && !compareToEvt.evt.IsAllDayEvent) {
                return -1;
            } else if (!evt.IsAllDayEvent && compareToEvt.evt.IsAllDayEvent) {
                return 1;
            }

            if (!evt.IsAllDayEvent && !compareToEvt.evt.IsAllDayEvent) {
              List<String> partsStart = startTime.split(':');
              List<String> partsEnd = endTime.split(':');
              String strDate = ('0' + partsStart[0]).right(2) + ('0' + partsStart[1]).right(2) + ('0' + partsEnd[0]).right(2) + ('0' + partsEnd[1]).right(2);
              String strDate1 = ('0' + partsStart[0]).right(2) + ('0' + partsStart[1]).right(2);
              String strDate2 = ('0' + ((partsEnd[0] < partsStart[0] ? 24 : 0) + Integer.valueOf(partsEnd[0]))).right(2) + ('0' + partsEnd[1]).right(2);

              List<String> partsStartCompareTo = compareToEvt.startTime.split(':');
              List<String> partsEndCompareTo = compareToEvt.endTime.split(':');
              String strDateCompareTo = ('0' + partsStartCompareTo[0]).right(2) + ('0' + partsStartCompareTo[1]).right(2) + ('0' + partsEndCompareTo[0]).right(2) + ('0' + partsEndCompareTo[1]).right(2);
              String strDateCompareTo1 = ('0' + partsStartCompareTo[0]).right(2) + ('0' + partsStartCompareTo[1]).right(2);
              String strDateCompareTo2 = ('0' + ((partsEndCompareTo[0] < partsStartCompareTo[0] ? 24 : 0) + Integer.valueOf(partsEndCompareTo[0]))).right(2) + ('0' + partsEndCompareTo[1]).right(2);

              if (strDate1 > strDateCompareTo1) {
                  return 1;
              } else if (strDate1 < strDateCompareTo1) {
                  return -1;
              }

              if (strDate2 < strDateCompareTo2) {
                  return 1;
              } else if (strDate2 > strDateCompareTo2) {
                  return -1;
              }
            }

            if (sortNo > compareToEvt.sortNo) {
                return 1;
            } else if (sortNo < compareToEvt.sortNo) {
                return -1;
            }

            return 0;
        }

    }

     /**
     * メールアドレス用のインナークラス
     */
     private class MailAddress {

        public String userId{get;set;}
        public String userName{get;set;}
        public String email{get;set;}
        public boolean isDeleted{get;set;}


        public String getUserNameDisplayed() {
          String sReturn = '';
          for (integer i = 0; i < userName.length() ; i++) {
            sReturn += '<span>' + userName.substring(i, i+1) + '</span>';
          }
          return sReturn;
        }

        public MailAddress () {
            userId = null;
            userName = null;
            email = null;
        }

        public MailAddress (String Id,String Name,String mail) {
            userId = Id;
            userName = Name;
            email = mail;
            isDeleted = false;
        }
    }

    private static Boolean validateEmail(String email) {

        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        if (!Pattern.compile(emailRegex).matcher(email).matches())
            res = false;

        if(email.indexof('@') < 0 ||
           ((email.substring(email.indexof('@')) != '@kddi.com') &&
            (email.substring(email.indexof('@')) != '@kddi.biz.ezweb.ne.jp') &&
            (email.substring(email.indexof('@')) != '@k-pcd.com') &&
            (email.substring(email.indexof('@')) != '@au-mobile.com') &&
            (email.substring(email.indexof('@')) != '@okinawa-ve.com') &&
            (email.substring(email.indexof('@')) != '@dummy.for.test.com'))) {
          res = false;
        }

        return res;

    }


    public PageReference addAddressManualTo() {

      messageError = '';
      classInputManualEmailTo = '';

      // 手入力が未入力だった場合
      if (mailToManualList.length() == 0) {
          //手入力にメールアドレスを入力してください。
          return null;
      }

      String[] manualList = mailToManualList.split('(\r\n|\r|\n|,)',0);
      List<String> lsEmailError = new List<String>();

      for (String manual : manualList) {
        if (manual.trim().length() > 0)
        if (!validateEmail(manual.trim())) {
            messageError = 'KDDIドメインのアドレスしか設定できません。';
            classInputManualEmailTo = 'error';
            lsEmailError.add(manual.trim());
        } else {
          // Check if the email is not already in the list
          boolean fAlreadyInTheList = false;
          for (MailAddress madr : mailToAddressList) {
            if (!madr.isDeleted && madr.userId == NULL && madr.userName == '手入力' && madr.email == manual) {
              fAlreadyInTheList = true;
            }
          }
          if (!fAlreadyInTheList) {
            mailToAddressList.add(new MailAddress(null, '手入力', manual));
          }
        }
      }

      mailToManualList = '';
      for (String ml : lsEmailError) {
        if (mailToManualList.length() > 0) {
          mailToManualList += '\n';
        }
        mailToManualList += ml;
      }

      return null;
    }

    public PageReference addAddressManualCc() {

      messageError = '';
      classInputManualEmailCc = '';

      // 手入力が未入力だった場合
      if (mailCcManualList.length() == 0) {
          //手入力にメールアドレスを入力してください。
          return null;
      }

      String[] manualList = mailCcManualList.split('(\r\n|\r|\n|,)',0);
      List<String> lsEmailError = new List<String>();

      for (String manual : manualList) {
        if (manual.trim().length() > 0)
        if (!validateEmail(manual.trim())) {
            messageError = 'KDDIドメインのアドレスしか設定できません。';
            classInputManualEmailCc = 'error';
            lsEmailError.add(manual.trim());
        } else {
          // Check if the email is not already in the list
          boolean fAlreadyInTheList = false;
          for (MailAddress madr : mailCcAddressList) {
            if (!madr.isDeleted && madr.userId == NULL && madr.userName == '手入力' && madr.email == manual) {
              fAlreadyInTheList = true;
            }
          }
          if (!fAlreadyInTheList) {
            mailCcAddressList.add(new MailAddress(null, '手入力', manual));
          }
        }
      }

      mailCcManualList = '';
      for (String ml : lsEmailError) {
        if (mailCcManualList.length() > 0) {
          mailCcManualList += '\n';
        }
        mailCcManualList += ml;
      }

      return null;
    }

    public PageReference addAddressManualBcc() {

      messageError = '';
      classInputManualEmailBcc = '';

      // 手入力が未入力だった場合
      if (mailBccManualList.length() == 0) {
          //手入力にメールアドレスを入力してください。
          return null;
      }

      String[] manualList = mailBccManualList.split('(\r\n|\r|\n|,)',0);
      List<String> lsEmailError = new List<String>();

      for (String manual : manualList) {
        if (manual.trim().length() > 0)
        if (!validateEmail(manual.trim())) {
            messageError = 'KDDIドメインのアドレスしか設定できません。';
            classInputManualEmailBcc = 'error';
            lsEmailError.add(manual.trim());
        } else {
          // Check if the email is not already in the list
          boolean fAlreadyInTheList = false;
          for (MailAddress madr : mailBccAddressList) {
            if (!madr.isDeleted && madr.userId == NULL && madr.userName == '手入力' && madr.email == manual) {
              fAlreadyInTheList = true;
            }
          }
          if (!fAlreadyInTheList) {
            mailBccAddressList.add(new MailAddress(null, '手入力', manual));
          }
        }
      }

      mailBccManualList = '';
      for (String ml : lsEmailError) {
        if (mailBccManualList.length() > 0) {
          mailBccManualList += '\n';
        }
        mailBccManualList += ml;
      }

      return null;
    }

    public PageReference patternSaveFuncOtherName() {
      return patternSaveFunc(false);
    }

    public PageReference patternSaveFuncSameName() {
      return patternSaveFunc(true);
    }

    private PageReference patternSaveFunc(boolean isSamePatternName) {

        String patternName = patternData;
system.debug('patternName: ' + patternName);

        if (isSamePatternName) {
          changePatternText = getCurrentPatternName(patternName);
        } else {
          changePatternText = changePatternTextNewName;
        }
system.debug('changePatternText: ' + changePatternText);

        String joinToAddress = '';
        String joinCcAddress = '';
        String joinBccAddress = '';

        // パターン保存に使用する区切り文字が入っていた場合エラー
//        if (validatePatternNameCheck(changePatternText)) {
            //[]が入った内容は保存できません。他の文字を使用してください。
  //          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_05));
    //        return null;
      //  }

        // TOアドレス欄
        for (mailAddress mail : mailToAddressList) {
          if (!mail.isDeleted) {
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
        }
        // CCアドレス欄
        for (mailAddress mail : mailCcAddressList) {
          if (!mail.isDeleted) {
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
        }
        // BCCアドレス欄
        for (mailAddress mail : mailBccAddressList) {
          if (!mail.isDeleted) {
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
            }
            // パターン２の場合
            if (patternName.equals(DISPLAY_PATTERN_2)) {
                myUser.MailAddressMemory2__c = memoryStr; //メモリ２に登録
            }
            // パターン３の場合
            if (patternName.equals(DISPLAY_PATTERN_3)) {
                myUser.MailAddressMemory3__c = memoryStr; //メモリ３に登録
            }
            // パターン４の場合
            if (patternName.equals(DISPLAY_PATTERN_4)) {
                myUser.MailAddressMemory4__c = memoryStr; //メモリ４に登録
            }
            // パターン５の場合
            if (patternName.equals(DISPLAY_PATTERN_5)) {
                myUser.MailAddressMemory5__c = memoryStr; //メモリ５に登録
            }
            try {
                update myUser;
            } catch (Exception e) {
                system.debug(e.getMessage());
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'システムエラーが発生しました。システム管理者にお問い合わせください。'));
            }

        }
        getSelectPattern();

        patternDataToSend = patternData;

        return null;

     }



    /**
     * 保持した文字列をテキストエリアに変換に各項目にセットする
     * @param memoryStr　保持したアドレス群
     **/
    private String getCurrentPatternName (String currentPattern) {

      String sCurrentMailAddressMemory = '';
      String sCurrentPatternName = '';

      if (DISPLAY_PATTERN_1.equals(currentPattern)) {
          sCurrentMailAddressMemory = myUser.MailAddressMemory1__c;
      }
      if (DISPLAY_PATTERN_2.equals(currentPattern)) {
          sCurrentMailAddressMemory = myUser.MailAddressMemory2__c;
      }
      if (DISPLAY_PATTERN_3.equals(currentPattern)) {
          sCurrentMailAddressMemory = myUser.MailAddressMemory3__c;
      }
      if (DISPLAY_PATTERN_4.equals(currentPattern)) {
          sCurrentMailAddressMemory = myUser.MailAddressMemory4__c;
      }
      if (DISPLAY_PATTERN_5.equals(currentPattern)) {
          sCurrentMailAddressMemory = myUser.MailAddressMemory5__c;
      }

      if (sCurrentMailAddressMemory != null) {
        Integer toCount = sCurrentMailAddressMemory.indexOf('[TO]');

        if (toCount >= 0){
            sCurrentPatternName = sCurrentMailAddressMemory.subString(0, toCount);
        } else {
            sCurrentPatternName = sCurrentMailAddressMemory;
        }
      }

      if (sCurrentPatternName == '') {
        sCurrentPatternName = currentPattern;
      }
      return sCurrentPatternName;
    }

    public PageReference addAddressOtherOrg() {
      return addAddressOrg(false);
    }

    public PageReference addAddressOwnOrg() {
      return addAddressOrg(true);
    }

    private PageReference addAddressOrg(boolean isOwnOrg) {

system.debug('addAddressOrg: ' + isOwnOrg);
      List<User> lsUsrGroup = isOwnOrg ? lsUsrOwnGroup : lsUsrOtherGroup;
system.debug('Users selected #: ' + lsUsrGroup.size());

      if (!isOwnOrg) {
        // reset the status for own group
        for (User usr : lsUsrOwnGroup) {
          usr.TechnicalAlwaysFalse__c = false;
        }
      }

      for (User usrToAdd : lsUsrGroup) {
system.debug('usrToAdd: ' + usrToAdd.Name + ' - ' + usrToAdd.TechnicalAlwaysFalse__c);

        if (usrToAdd.TechnicalAlwaysFalse__c) {
          usrToAdd.TechnicalAlwaysFalse__c = false;

          // toAddを押下した場合テキストエリアにEmailアドレスをセットする。
          if (currentMailList.equals('To')) {

            // Check if the user is not already in the list
            boolean fAlreadyInTheList = false;
            for (MailAddress madr : mailToAddressList) {
              if (!madr.isDeleted && madr.userId == usrToAdd.Id) {
                fAlreadyInTheList = true;
              }
            }
            if (!fAlreadyInTheList) {
              mailToAddressList.add(new MailAddress(String.ValueOf(usrToAdd.Id), usrToAdd.Name, usrToAdd.Email));
            }

          }
          // ccAddを押下した場合テキストエリアにEmailアドレスをセットする。
          if (currentMailList.equals('Cc')) {

            // Check if the user is not already in the list
            boolean fAlreadyInTheList = false;
            for (MailAddress madr : mailCcAddressList) {
              if (!madr.isDeleted && madr.userId == usrToAdd.Id) {
                fAlreadyInTheList = true;
              }
            }
            if (!fAlreadyInTheList) {
              mailCcAddressList.add(new MailAddress(String.ValueOf(usrToAdd.Id), usrToAdd.Name, usrToAdd.Email));
            }

          }
          // bccAddを押下した場合テキストエリアにEmailアドレスをセットする。
          if (currentMailList.equals('Bcc')) {

            // Check if the user is not already in the list
            boolean fAlreadyInTheList = false;
            for (MailAddress madr : mailBccAddressList) {
              if (!madr.isDeleted && madr.userId == usrToAdd.Id) {
                fAlreadyInTheList = true;
              }
            }
            if (!fAlreadyInTheList) {
              mailBccAddressList.add(new MailAddress(String.ValueOf(usrToAdd.Id), usrToAdd.Name, usrToAdd.Email));
            }

          }

        }
      }


      return null;
    }



    /**
     * 活動内容をメールで送信
     */
     public PageReference sendEmail() {

        messageError = '';

        List<User> onlyToUser = new List<User>();
        Id onlyToUserId = null;
        Boolean onlyToFlg = false;
        // Toが未選択の場合エラー
        if (mailToAddressListConfirm.size() == 0) {
            messageError = System.Label.auSendEventMail_MSG_08;
            return null;
        }
        if (resultTextArea == NULL || resultTextArea.trim().length() == 0) {
            //Toが全て未選択の場合送信できません。１つ以上選択してください。
            messageError = 'メール本文を入力してください。';
            return null;
        }
        //@todo []の入力チェックは必須。メールアドレスのチェックができればなおよし
        //Boolean isEmail = Pattern.matches('^[a-zA-Z0-9]',ccAdress1);
        String[] mailToStrList = new String[0];
        String[] mailCcStrList = new String[0];
        String[] mailBccStrList = new String[0];

        if (mailToAddressListConfirm.size() > 0) {
            String mailToStr = '';
            for (mailAddress to : mailToAddressListConfirm) {
                system.debug(to.email);
                if (mailToStr == '') {
                    mailToStr += to.email;
                } else {
                    mailToStr += ',' + to.email;
                }
            }
            system.debug(mailToStr);
            mailToStrList = mailToStr.split(',',0);
        }
        if (mailCcAddressListConfirm.size() > 0) {
            String mailCcStr = '';
            for (mailAddress cc : mailCcAddressListConfirm) {
                if (mailCcStr == '') {
                    mailCcStr += cc.email;
                } else {
                    mailCcStr += ',' + cc.email;
                }
            }
            system.debug(mailCcStr);
            mailCcStrList = mailCcStr.split(',',0);
        }
        if (mailBccAddressListConfirm.size() > 0) {
            String mailBccStr = '';
            for (mailAddress bcc : mailBccAddressListConfirm) {
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
        if (emailHeader != NULL && emailHeader.trim().length() > 0) {
          bodyStr = emailHeader + '\n' + bodyStr;
        }

        system.debug(bodyStr);
        try {

            // Save the signature of the user
            if (emailSignature != myUser.Signature || emailHeader != myUser.EmailHeader__c) {
              myUser.Signature = emailSignature;
              myUser.EmailHeader__c = emailHeader;
              Update myUser;
            }

            system.debug(mailToStrList.size());
            system.debug(mailCcStrList.size());
            system.debug(mailBccStrList.size());
            auSendEmailUtil cls = new auSendEmailUtil();
            // 宛先が一件だけの場合
            if (mailToStrList.size() == 1
                && mailCcStrList.size()==0
                && mailBccStrList.size()==0) {
                String emailStr = mailToStrList[0];
                onlyToUser = [SELECT Id FROM User WHERE Email =:emailStr];
                // Toが１件且つ存在しているユーザだった場合targetobjectIdのフラグオン
                if (!onlyToUser.isEmpty()) {
                    onlyToUserId = onlyToUser[0].Id;
                    onlyToFlg = true;
                }
            }
            cls.createTOCCBCCSendMessage(null, String.valueOf(onlyToUserId),
                                         mailToStrList, mailCcStrList, mailBccStrList,
                                         mailTitle, bodyStr, onlyToFlg);

            List<auSendEmailUtil.SendResponse> lsResp = cls.sendMail();
            boolean hasError = false;
            String errorMessage = '';
            for (auSendEmailUtil.SendResponse resp : lsResp) {
                if (!resp.success) {
                    hasError = true;
                    errorMessage = resp.message;
                }
            }

            if (hasError) {
                messageError = System.Label.auSendEventMail_MSG_10 + '\n' + errorMessage;
                return null;
            }

            // Save the flag sentStatus
            // I don't understand how it is possible to happen (except apart than if the customer has 2 screens launched) but there
            // is sometime an error because some data we try to update is already deleted.
            // We will requery the rows before updating it
            // List<Event> lsEvtSent = new List<Event>();
            // for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
            //   if (clsEvt.isSelected) {
            //     clsEvt.evt.ActivityReportSent__c = true;
            //     lsEvtSent.add(clsEvt.evt);
            //   }
            // }
            // Upsert lsEvtSent;

            List<Id> lsEvtSentId = new List<Id>();
            for (clsEventCurrentDay clsEvt : clsDayCurrentDay) {
              if (clsEvt.isSelected) {
                lsEvtSentId.add(clsEvt.evt.Id);
              }
            }
            List<Event> lsEvtSent = [SELECT Id, ActivityReportSent__c FROM Event WHERE Id IN :lsEvtSentId AND ActivityReportSent__c = False];
            for (Event evt : lsEvtSent) {
              evt.ActivityReportSent__c = True;
            }
            if (lsEvtSent != NULL && lsEvtSent.size() > 0) {
              Upsert lsEvtSent;
            }

            clsDayCurrentDay = new List<clsEventCurrentDay>();
            lsDaysOfMonth = new List<List<clsDay>>();
            refreshMonth();
            showDay();

        } catch (Exception e) {
            system.debug(e.getMessage());
            //メールの送信に失敗しました。メールアドレスの確認又はシステム管理者にお問い合わせください。
            messageError = System.Label.auSendEventMail_MSG_10 + '\n' + e.getMessage();
        }
        return null;
    }


}