global with sharing class kdGpsTrackingDetailCtrl {

  public static final String PARAM_ID = 'id';

  public static final String USER_BASE_QUERY = ' SELECT id, Name, Profile.Name, UserRole.Name, UserRole.DeveloperName, TechnicalString__c FROM User ';
  public static final String USER_BASE_QUERY_SA = ' SELECT id, (Select BusinessLocation__r.BusinessLocationName__c from saBusinessLocationDetail_user__r order by Type__c Nulls Last), Name, Profile.Name, UserRole.Name, UserRole.DeveloperName, TechnicalString__c FROM User ';
  
  public static final Integer MAX_MARKER_DISPLAYED = 100; // 1 ~ 100

  public String previewURL{get; set;} 
  public String currentInquiryId{get; set;} 
  public Boolean isValid{get; set;}
  public UserManage idm{get; set;}
  public Boolean isNew{get; set;}
  public double currentScrollValue{get; set;}  
    
  private User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
  private Boolean isUserProfileEvolva(){
    return currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
           currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
  }

    public kdGpsTrackingDetailCtrl() {


      currentScrollValue = 0;
      this.isValid = false;

      User rec = null;

      try {
      Map<String, String> params = Apexpages.currentPage().getParameters();
        
      if (params.containsKey(PARAM_ID)) {
        String targetId = params.get(PARAM_ID);
        rec = getTargetRecord(targetId);
        if (rec != NULL) {
          idm = new UserManage(rec); 
        }
      }      

      this.isValid = true;
     
      } catch (Exception e) {
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, '不正な操作が行われました。' + e.getMessage()));
        return;
      }

    }


  

  private User getTargetRecord(String targetId) {
    User targetaRecord = null;
    List<User> recs = [SELECT id, name
                       FROM User
                       WHERE Id =: targetId];

    if (recs != null && recs.size() > 0) {
      targetaRecord = recs.get(0);
    } else {
      throw new KDDIException('');
    }
    return targetaRecord;
  }



  public static List<SelectOption> getSAClassificationOptions() {

      List<SelectOption> options = new List<SelectOption>();
              
      for( Schema.PicklistEntry f : User.SAClassification__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(f.getValue(), f.getLabel()));
      }
    options.add(new SelectOption('BLANK', '設定無し'));

      return options;

    }

    public void dummyAction() {}

    private class gpsData {

        public Id idSfdc{get; set;}  
        public double latitude{get; set;}  
        public double longitude{get; set;}  
        public String timeFormatted{get; set;}
        public Boolean isMain{get; set;}
        public Boolean isMarkerDisplayed{get; set;}

        public String getLatitudeFormatted() {
          return convertLatitude(latitude);
        }

        public String getLongitudeFormatted() {
          return convertLongitude(longitude);
        }

        public gpsData() {
          idSfdc = NULL;
          latitude = 0;
          longitude = 0;
          timeFormatted = '';
          isMain = false;
          isMarkerDisplayed = false;
        }

        public gpsData(Id idSfdc, double latitude, double longitude, String timeFormatted, Boolean isMain, Boolean isMarkerDisplayed) {
          this.idSfdc = idSfdc;
          this.latitude = latitude;
          this.longitude = longitude;
          this.timeFormatted = timeFormatted;
          this.isMain = isMain;
          this.isMarkerDisplayed = isMarkerDisplayed;
        }

    }


    public class UserManage {
        public User parentRec{get; set;}
        public List<kdGpsTracking__c> lsGpsRawData{get; set;}

        public String targetAccountId{get; set;}

        public Id idGpsMainData{get; set;}  
        public gpsData gpsMainData{get; set;}  
        public Boolean gpsMainDataSet{get; set;}  
        public List<gpsData> lsGpsData{get; set;}  

        public double gps1_lat{get; set;}  
        public double gps1_long{get; set;}  
        public String gps1_time{get; set;}  
        public double gps2_lat{get; set;}  
        public double gps2_long{get; set;}  
        public String gps2_time{get; set;}  
        public double gps3_lat{get; set;}  
        public double gps3_long{get; set;}  
        public String gps3_time{get; set;}  
        public double gps4_lat{get; set;}  
        public double gps4_long{get; set;}  
        public String gps4_time{get; set;}  
        public double gps5_lat{get; set;}  
        public double gps5_long{get; set;}  
        public String gps5_time{get; set;}  
        public double gps6_lat{get; set;}  
        public double gps6_long{get; set;}  
        public String gps6_time{get; set;}  
        public double gps7_lat{get; set;}  
        public double gps7_long{get; set;}  
        public String gps7_time{get; set;}  
        public double gps8_lat{get; set;}  
        public double gps8_long{get; set;}  
        public String gps8_time{get; set;}  
        public double gps9_lat{get; set;}  
        public double gps9_long{get; set;}  
        public String gps9_time{get; set;}  
        public double gps10_lat{get; set;}  
        public double gps10_long{get; set;}  
        public String gps10_time{get; set;}  
        public double gps11_lat{get; set;}  
        public double gps11_long{get; set;}  
        public String gps11_time{get; set;}  
        public double gps12_lat{get; set;}  
        public double gps12_long{get; set;}  
        public String gps12_time{get; set;}  
        public double gps13_lat{get; set;}  
        public double gps13_long{get; set;}  
        public String gps13_time{get; set;}  
        public double gps14_lat{get; set;}  
        public double gps14_long{get; set;}  
        public String gps14_time{get; set;}  
        public double gps15_lat{get; set;}  
        public double gps15_long{get; set;}  
        public String gps15_time{get; set;}  
        public double gps16_lat{get; set;}  
        public double gps16_long{get; set;}  
        public String gps16_time{get; set;}  
        public double gps17_lat{get; set;}  
        public double gps17_long{get; set;}  
        public String gps17_time{get; set;}  
        public double gps18_lat{get; set;}  
        public double gps18_long{get; set;}  
        public String gps18_time{get; set;}  
        public double gps19_lat{get; set;}  
        public double gps19_long{get; set;}  
        public String gps19_time{get; set;}  
        public double gps20_lat{get; set;}  
        public double gps20_long{get; set;}  
        public String gps20_time{get; set;}  

        public UserManage(User parentRec) {

            idGpsMainData = NULL;
            gpsMainData = new gpsData();
            gpsMainDataSet = false;
            lsGpsData = new List<gpsData>();

            gps1_lat = 0;
            gps1_long = 0;
            gps2_lat = 0;
            gps2_long = 0;
            gps3_lat = 0;
            gps3_long = 0;
            gps4_lat = 0;
            gps4_long = 0;
            gps5_lat = 0;
            gps5_long = 0;
            gps6_lat = 0;
            gps6_long = 0;
            gps7_lat = 0;
            gps7_long = 0;
            gps8_lat = 0;
            gps8_long = 0;
            gps9_lat = 0;
            gps9_long = 0;
            gps10_lat = 0;
            gps10_long = 0;
            gps11_lat = 0;
            gps11_long = 0;
            gps12_lat = 0;
            gps12_long = 0;
            gps13_lat = 0;
            gps13_long = 0;
            gps14_lat = 0;
            gps14_long = 0;
            gps15_lat = 0;
            gps15_long = 0;
            gps16_lat = 0;
            gps16_long = 0;
            gps17_lat = 0;
            gps17_long = 0;
            gps18_lat = 0;
            gps18_long = 0;
            gps19_lat = 0;
            gps19_long = 0;
            gps20_lat = 0;
            gps20_long = 0;

            this.parentRec = parentRec;
            this.lsGpsRawData = [SELECT Id, GeoLocation__c, GeoLocation__Longitude__s, GeoLocation__Latitude__s, Datetime__c
                                 FROM   kdGpsTracking__c
                                 WHERE  User__c = :parentRec.Id
                                 AND    Datetime__c != NULL
                                 AND    GeoLocation__Latitude__s != NULL
                                 AND    GeoLocation__Longitude__s != NULL
                                 ORDER BY Datetime__c DESC
                                 LIMIT 1000];

            Integer idx = 0;
            for (kdGpsTracking__c gps : lsGpsRawData) {

              idx++;

              if (idx == 1) {
                idGpsMainData = gps.Id;
                gpsMainData = new gpsData(gps.Id,
                                          (double)gps.GeoLocation__Latitude__s,
                                          (double)gps.GeoLocation__Longitude__s,
                                          gps.Datetime__c.format('yyyy/MM/dd HH:mm'),
                                          true, true);
                gpsMainDataSet = true;
              }

              lsGpsData.add(new gpsData(gps.Id,
                                        (double)gps.GeoLocation__Latitude__s,
                                        (double)gps.GeoLocation__Longitude__s,
                                        gps.Datetime__c.format('yyyy/MM/dd HH:mm'),
                                        idx == 1, idx <= MAX_MARKER_DISPLAYED));

              if (idx == 1) {
                gps1_lat = gps.GeoLocation__Latitude__s;
                gps1_long = gps.GeoLocation__Longitude__s;
                gps1_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 2) {
                gps2_lat = gps.GeoLocation__Latitude__s;
                gps2_long = gps.GeoLocation__Longitude__s; 
                gps2_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 3) {
                gps3_lat = gps.GeoLocation__Latitude__s;
                gps3_long = gps.GeoLocation__Longitude__s; 
                gps3_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 4) {
                gps4_lat = gps.GeoLocation__Latitude__s;
                gps4_long = gps.GeoLocation__Longitude__s; 
                gps4_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 5) {
                gps5_lat = gps.GeoLocation__Latitude__s;
                gps5_long = gps.GeoLocation__Longitude__s; 
                gps5_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 6) {
                gps6_lat = gps.GeoLocation__Latitude__s;
                gps6_long = gps.GeoLocation__Longitude__s; 
                gps6_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 7) {
                gps7_lat = gps.GeoLocation__Latitude__s;
                gps7_long = gps.GeoLocation__Longitude__s; 
                gps7_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 8) {
                gps8_lat = gps.GeoLocation__Latitude__s;
                gps8_long = gps.GeoLocation__Longitude__s; 
                gps8_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 9) {
                gps9_lat = gps.GeoLocation__Latitude__s;
                gps9_long = gps.GeoLocation__Longitude__s; 
                gps9_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 10) {
                gps10_lat = gps.GeoLocation__Latitude__s;
                gps10_long = gps.GeoLocation__Longitude__s; 
                gps10_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 11) {
                gps11_lat = gps.GeoLocation__Latitude__s;
                gps11_long = gps.GeoLocation__Longitude__s; 
                gps11_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 12) {
                gps12_lat = gps.GeoLocation__Latitude__s;
                gps12_long = gps.GeoLocation__Longitude__s; 
                gps12_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 13) {
                gps13_lat = gps.GeoLocation__Latitude__s;
                gps13_long = gps.GeoLocation__Longitude__s; 
                gps13_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 14) {
                gps14_lat = gps.GeoLocation__Latitude__s;
                gps14_long = gps.GeoLocation__Longitude__s; 
                gps14_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 15) {
                gps15_lat = gps.GeoLocation__Latitude__s;
                gps15_long = gps.GeoLocation__Longitude__s; 
                gps15_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 16) {
                gps16_lat = gps.GeoLocation__Latitude__s;
                gps16_long = gps.GeoLocation__Longitude__s; 
                gps16_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 17) {
                gps17_lat = gps.GeoLocation__Latitude__s;
                gps17_long = gps.GeoLocation__Longitude__s; 
                gps17_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 18) {
                gps18_lat = gps.GeoLocation__Latitude__s;
                gps18_long = gps.GeoLocation__Longitude__s; 
                gps18_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 19) {
                gps19_lat = gps.GeoLocation__Latitude__s;
                gps19_long = gps.GeoLocation__Longitude__s; 
                gps19_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else if (idx == 20) {
                gps20_lat = gps.GeoLocation__Latitude__s;
                gps20_long = gps.GeoLocation__Longitude__s; 
                gps20_time = gps.Datetime__c.format('yyyy/MM/dd HH:mm');
              } else {
                // break;                
              }
            }

        }

        public void refreshDisplayedData() {

            Integer iDisplayedMarker = 0;
            boolean isMainFound = false;

            for (gpsData gps : lsGpsData) {

              if (gps.idSfdc == idGpsMainData) {
                isMainFound = true;
                gps.isMain = true;
                gps.isMarkerDisplayed = true;
                iDisplayedMarker++;
                gpsMainData = gps;
              } else {
                gps.isMain = false;

                if (isMainFound && iDisplayedMarker < MAX_MARKER_DISPLAYED) {
                  gps.isMarkerDisplayed = true;
                  iDisplayedMarker++;
                } else {
                  gps.isMarkerDisplayed = false;                  
                }
              }

            }
        }

        public List<gpsData> getlsGpsDataMain() {

            List<gpsData> lsReturn = new List<gpsData>();

            for (gpsData gps : lsGpsData) {
              if (gps.isMain) {
                lsReturn.add(gps);
              }
            }
            return lsReturn;
        }

        public List<gpsData> getlsGpsDataNotMain() {

            List<gpsData> lsReturn = new List<gpsData>();
            boolean fMainFound = false;

            for (gpsData gps : lsGpsData) {
              if (!gps.isMain && gps.isMarkerDisplayed) {
                lsReturn.add(gps);
              }
            }
            return lsReturn;
        }

    }





    public static String joinWhereConditions(List<String> conditions) {
        String ret;
        if (conditions == null) {
            conditions = new List<String>();
        }
        for (String condition: conditions) {
            if (ret != null) {
                ret += ' AND ' + condition;
            } else {
                ret = ' WHERE ' + condition;
            }
        }
        if (ret == null) {
            ret = '';
        }
        return ret;
    }

    public Double offset {
      get {
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
      }
    }








    public static String convertGps(Decimal latitude, Decimal longitude){
        return convertLatitude(latitude) + ' ' + convertLongitude(longitude);
    }

    public static String convertLatitude(Decimal latitude){
        String result = '';
        if(latitude != null){
            String direction = 'N';
            if(latitude < 0){
                direction = 'S';
            }
            result = convertGps(latitude) + direction;
        }
        return result;
    }

    public static String convertLongitude(Decimal longitude){
        String result = '';
        if(longitude != null){
            String direction = 'E';
            if(longitude < 0){
                direction = 'W';
            }
            result = convertGps(longitude) + direction;
        }
        return result;
    }
        
    private static String convertGps(Decimal d){
        d = d.abs();

        //degrees
        Integer i = d.intValue();
        String s = String.valueOf(i) + '°';
        
        //minutes
        d = d - i;
        d = d * 60;
        i = d.intValue();
        s = s + String.valueOf(i) + '\'';
        
        //seconds
        d = d - i;
        d = d * 60;
        i = d.round().intValue();
        s = s + String.valueOf(i) + '"';
        
        return s;
    }





}