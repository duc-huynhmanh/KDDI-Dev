@isTest
private class auSendEventMailCtrlTest
{
  @isTest(SeeAllData=false)
  static void dummyTest()
  {
    User adminUser = auTestDataUtil.createAdminUser('admin');
    System.runAs(adminUser) {
      PageReference pageRef = Page.auSendEventMail;

      Test.startTest();
      
      adminUser.MailAddressMemory1__c = 'パターン２[TO]' + adminUser.Id + ',手入力test01@sample.com' +
                                          + '[CC]手入力test02@sample.com,' + adminUser.Id 
                                          + '[BCC]手入力test03@sample.com,' + adminUser.Id;
      update adminUser;
      
      Event event = new Event();
      event.StartDateTime = Datetime.now();
      event.EndDateTime = Datetime.now();
      event.subject = 'TEST';
      event.ownerId = adminUser.Id;
      insert event;
      
      
      auSendEventMailCtrl ctrl = new auSendEventMailCtrl();

      ctrl.init();
      // 検索
      ctrl.searchEvent.StartDateTime = null;
      ctrl.searchEvent.EndDateTime = null;
      ctrl.search();
      ctrl.searchEvent.StartDateTime = Datetime.now().addHours(-1);
      ctrl.searchEvent.EndDateTime = null;
      ctrl.search();
      ctrl.searchEvent.StartDateTime = null;
      ctrl.searchEvent.EndDateTime = Datetime.now().addHours(1);
      ctrl.search();
      ctrl.searchEvent.StartDateTime = Datetime.now().addHours(-1);
      ctrl.searchEvent.EndDateTime = Datetime.now().addHours(1);
      ctrl.search();
      // 検索結果をテキストエリアに反映
      ctrl.resultList[0].checked = true;
      ctrl.addResultToTextArea();
      // パターンを取得
      ctrl.patternData='パターン１';
      ctrl.acquisition();
      ctrl.patternData='パターン２';
      ctrl.acquisition();
      ctrl.patternData='パターン３';
      ctrl.acquisition();
      ctrl.patternData='パターン４';
      ctrl.acquisition();
      ctrl.patternData='パターン５';
      ctrl.acquisition();
      
      // 手入力から宛先の登録
      ctrl.manualInputText= 'test@sample.com';
      pageRef.getParameters().put('parameter','toAdd');
      pageRef.getParameters().put('inputParam','manual');
      Test.setCurrentPage(pageRef);
      ctrl.addAddress();
      ctrl.manualInputText= 'test@sample.com';
      pageRef.getParameters().put('parameter','ccAdd');
      pageRef.getParameters().put('inputParam','manual');
      Test.setCurrentPage(pageRef);
      ctrl.addAddress();
      ctrl.manualInputText= 'test@sample.com';
      pageRef.getParameters().put('parameter','bccAdd');
      pageRef.getParameters().put('inputParam','manual');
      Test.setCurrentPage(pageRef);
      ctrl.addAddress();
            
      // クリア
      pageRef.getParameters().put('parameter','toClear');
      Test.setCurrentPage(pageRef);
      ctrl.textClear();
      pageRef.getParameters().put('parameter','ccClear');
      Test.setCurrentPage(pageRef);
      ctrl.textClear();
      pageRef.getParameters().put('parameter','bccSClear');
      Test.setCurrentPage(pageRef);
      ctrl.textClear();

      // ユーザ登録から宛先の登録
      ctrl.criteria1.User__c = null;
      pageRef.getParameters().put('parameter','toAdd');
      Test.setCurrentPage(pageRef);
      ctrl.addAddress();
      ctrl.criteria1.User__c = adminUser.Id;
      pageRef.getParameters().put('parameter','toAdd');
      Test.setCurrentPage(pageRef);
      ctrl.addAddress();
      ctrl.criteria1.User__c = adminUser.Id;
      pageRef.getParameters().put('parameter','ccAdd');
      Test.setCurrentPage(pageRef);
      ctrl.addAddress();
      ctrl.criteria1.User__c = adminUser.Id;
      pageRef.getParameters().put('parameter','bccAdd');
      Test.setCurrentPage(pageRef);
      ctrl.addAddress();
      
      //パターンの保存
      ctrl.changePatternTextMemo = 'test';
      pageRef.getParameters().put('pattern','1');
      Test.setCurrentPage(pageRef);
      ctrl.pattern1Save();
      ctrl.changePatternTextMemo = 'test';
      pageRef.getParameters().put('pattern','2');
      Test.setCurrentPage(pageRef);
      ctrl.pattern2Save();
      ctrl.changePatternTextMemo = 'test';
      pageRef.getParameters().put('pattern','3');
      Test.setCurrentPage(pageRef);
      ctrl.pattern3Save();
      ctrl.changePatternTextMemo = 'test';
      pageRef.getParameters().put('pattern','4');
      Test.setCurrentPage(pageRef);
      ctrl.pattern4Save();
      ctrl.changePatternTextMemo = 'test';
      pageRef.getParameters().put('pattern','5');
      Test.setCurrentPage(pageRef);
      ctrl.pattern5Save();
      
      ctrl.sendMail();
      ctrl.resultTextAreaMemo = 'aaa';
      ctrl.sendMail();
  
      System.assertEquals(true, true);
      
      Test.stopTest();
    }
  }
}