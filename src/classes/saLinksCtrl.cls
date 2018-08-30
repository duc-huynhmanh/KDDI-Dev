public with sharing class saLinksCtrl {

    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}

    public List<clsLink> lsLinks {get;set;}

    public saLinksCtrl () {

      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name, Profile.Name, SAClassification__c
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl
              FROM USER WHERE Id = :UserInfo.getUserId()];

      lsLinks = new List<clsLink>();

      if (myUser.Profile.Name != auConstantCmn.PROFILE_EVOLVA_USER &&
          myUser.Profile.Name != auConstantCmn.PROFILE_EVOLVA_ADMIN_USER) {

        lsLinks.add(new clsLink('auチャンネル',
                                '/auHonbuDirect',
                                true));
      }

      if (myUser.Profile.Name != auConstantCmn.PROFILE_EVOLVA_USER &&
          myUser.Profile.Name != auConstantCmn.PROFILE_EVOLVA_ADMIN_USER &&
          myUser.Profile.Name != auConstantCmn.PROFILE_SA_USER_SA &&
          myUser.Profile.Name != auConstantCmn.PROFILE_SA_USER_CSA) {

        lsLinks.add(new clsLink('To Do',
                                '/saTasks',
                                true));

      }

      lsLinks.add(new clsLink('ユーザー設定',
                              '/saUsrSettings',
                              true));

      if (myUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER) {

        lsLinks.add(new clsLink('日報管理',
                                '/saDailyReportListForAdmin',
                                true));

        lsLinks.add(new clsLink('ヒアリング管理',
                                '/saHearingListForAdmin',
                                true));

        lsLinks.add(new clsLink('メッセージ管理',
                                '/saMessagesListForAdmin',
                                true));

        lsLinks.add(new clsLink('グループ管理',
                                '/_ui/core/chatter/groups/GroupListPage',
                                true));

      }

      if (myUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
          myUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER) {

        lsLinks.add(new clsLink('MobileCompany',
                                'https://csd.k-evolva.com/mmf/mbl/MblActLogin'));

        lsLinks.add(new clsLink('給与明細',
                                'https://csd.k-evolva.com/mcws/cws'));

        lsLinks.add(new clsLink('X-POINT',
                                'http://evorea/xpoint/login.jsp?domCd=evolva'));

        lsLinks.add(new clsLink('EmergencyCall',
                                'https://asp26.emc-call4th.jp/k-evolva/emcuser/showindexpage.do'));

        lsLinks.add(new clsLink('evogaku (社内e-learning)',
                                'https://evogaku.com'));

      }

      if (myUser.Profile.Name == auConstantCmn.PROFILE_SA_USER_SA ||
          myUser.Profile.Name == auConstantCmn.PROFILE_SA_USER_CSA) {

        if (myUser.SAClassification__c == auConstantCmn.USER_CLASSIFICATION_CONTRACTOR) {

          lsLinks.add(new clsLink('au Learning Stadium',
                                  'https://kddi.learningware.jp/kddi/login/index'));


        } else {

          lsLinks.add(new clsLink('Time Asset',
                                  'https://kinmu-ext.kddi.com/TimeAsset/Page/Cg00000L.aspx?CP=0&PG=0'));

          lsLinks.add(new clsLink('au Learning Stadium',
                                  'https://kddi.learningware.jp/kddi/login/index'));

          lsLinks.add(new clsLink('経費Bank',
                                  'https://ex1.keihibank.jp/kddi-c/'));

          lsLinks.add(new clsLink('Bulas ESS',
                                  'https://mobile2.bulas180.com/smart/'));

          lsLinks.add(new clsLink('Bulas Portal',
                                  'https://ess.bulas180.com/E0700_Bulas/'));

          lsLinks.add(new clsLink('EMC',
                                  'https://anpi-net.kddi.com/emc/emcuser/'));

        }

      }
    }

    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_LINKS;}

    public void dummyAction() {
    }

    public PageReference redirectIfNecessaryDesktop(){

        if (isIPhone) {
            // return Page.auScheduleMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        if (!isIPhone) {
            // return Page.auSchedule.setRedirect(true);
        }

        return null;
    }

    public class clsLink {

        public String linkTitle {get;set;}
        public String linkURL {get;set;}
        public Boolean linkSameWindow {get;set;}

        public clsLink(String title, String url){
          linkTitle = title;
          linkURL = url;
          linkSameWindow = false;
        }

        public clsLink(String title, String url, boolean sameWindow){
          linkTitle = title;
          linkURL = url;
          linkSameWindow = sameWindow;
        }

    }

}