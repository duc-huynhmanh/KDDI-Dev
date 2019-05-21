public with sharing class saDocumentsCtrl {

    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}

    public List<saDocuments__c> lsDocs {get;set;}
    public List<ContentVersion> lsContentVersion {get;set;}

    public String categoryName {get;set;}
    public String lCategoryName {get;set;}
    public String idDocumentCategory {get;set;}

    public saDocumentsCtrl () {

      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl
              FROM USER WHERE Id = :UserInfo.getUserId()];

      lsDocs = [SELECT Id, Category_small__c, Category_large__c,
                       (SELECT Id, ContentDocumentId FROM ContentDocumentLinks)
                FROM saDocuments__c
                WHERE RecordType.DeveloperName = 'SANX'
                ORDER BY SortNo__c, Category_small__c];

      lsContentVersion = new List<ContentVersion>();
      categoryName ='';

	  Map<String, Map<String, String>> dependentSelectMap;
	  List<Schema.PicklistEntry> parentEntryList;
	  List<Schema.PicklistEntry> childEntryList;

	  // 親選択リストのスキーマを取得する
	  parentEntryList = saDocuments__c.Category_large__c.getDescribe().getPicklistValues();
	  // 子選択リストのスキーマを取得する
	  childEntryList = saDocuments__c.Category_small__c.getDescribe().getPicklistValues();

	  // Mapを作成する
	  dependentSelectMap = createSelectListMap(parentEntryList, childEntryList);

	  system.debug(parentEntryList);
	  system.debug(childEntryList);
	  system.debug(dependentSelectMap.values());
	  system.debug(dependentSelectMap);
	  for(Schema.PicklistEntry SP :parentEntryList) {
		  system.debug(dependentSelectMap.get(SP.value).values());
  	  }
	  getCategoryMap();


    }


    public List<String> getLargeLabelList() {
  	  List<Schema.PicklistEntry> largeCatlabels = saDocuments__c.Category_large__c.getDescribe().getPicklistValues();
  	  List<String> largeLabelList = new List<String>();
  	  for(Schema.PicklistEntry lcl :largeCatlabels){
  		  largeLabelList.add(lcl.getLabel());
  	  }
  	  system.debug(largeLabelList);
  	  return largeLabelList;
    }


    public Map<String,Map<String,List<cdlView>>> getCategoryMap(){
		Map<String,Map<String,List<cdlView>>> categoryMap = new Map<String,Map<String,List<cdlView>>>();
		List<String> largeCatNameList = getLargeLabelList();
		for(String largeCatName :largeCatNameList){
			//make new list which have Large category name as key and put in categoryMap.
			categoryMap.put(largeCatName, new Map<String,List<cdlView>>());
		}


		 Map<String, Map<String, String>> dependentSelectMap;
		  List<Schema.PicklistEntry> parentEntryList;
		  List<Schema.PicklistEntry> childEntryList;

		  // 親選択リストのスキーマを取得する
		  parentEntryList = saDocuments__c.Category_large__c.getDescribe().getPicklistValues();
		  // 子選択リストのスキーマを取得する
		  childEntryList = saDocuments__c.Category_small__c.getDescribe().getPicklistValues();

		  // Mapを作成する
		  dependentSelectMap = createSelectListMap(parentEntryList, childEntryList);

		  system.debug(parentEntryList);
		  system.debug(childEntryList);
		  system.debug(dependentSelectMap.values());
		  system.debug(dependentSelectMap);
		  for(Schema.PicklistEntry SP :parentEntryList) {
			  system.debug(dependentSelectMap.get(SP.value).values());
	  	  }

		Map<String,List<string>> smallCatMap = new Map<String,List<string>>();
		List<String> largeCatNameList2 = getLargeLabelList();
		for(String largeCatName :largeCatNameList2){
			//make new list which have Large category name as key and put in smallCatMap.
			smallCatMap.put(largeCatName, new List<string>());
		}
		for(Schema.PicklistEntry pel :parentEntryList) {
			if(smallCatMap.containskey(pel.label)) {
				for(string d :dependentSelectMap.get(pel.value).values()) {
					smallCatMap.get(pel.label).add(d);
				}
			}
	  	}
		system.debug(smallCatMap);

		Map<String, List<cdlView>> docMap = new Map<String, List<cdlView>>();
		  for(Schema.PicklistEntry cel :childEntryList){
			  //make new list which have category name as key and put in categoryMap.
			  docMap.put(cel.label, new List<cdlView>());
		  }
		  system.debug(docMap);

		  List<saDocuments__c> lsDocs = [SELECT tolabel(Category_small__c),
		                                 (SELECT Id, ContentDocumentId, contentDocument.title FROM ContentDocumentLinks
		                                		 ORDER BY ContentDocument.createdDate DESC LIMIT 1)
		                                 FROM saDocuments__c WHERE RecordType.DeveloperName = 'SANX'
		                                 ORDER BY SortNo__c NULLS FIRST];

		  system.debug(lsDocs);

		  //put ContentDocumentId and samll categoryName(Category_small__c) in cdlViewMap.
		  Map<String, cdlView> cdlViewMap = new Map<String, cdlView>();
		  for(saDocuments__c doc :lsDocs) {
			  for(ContentDocumentLink cdl :doc.ContentDocumentLinks) {
				  cdlView cdlv = new cdlView();
				  cdlv.category = doc.Category_small__c;
				  cdlViewMap.put(cdl.ContentDocumentId,cdlv);
			  }
		  }

		//get data to display VF.
		  List<ContentVersion> cdvList = [SELECT Id, ContentDocumentId, Title,FileExtension
		                            FROM ContentVersion
		                            WHERE ContentDocumentId IN :cdlViewMap.keySet()];

		  //put Id and Title of ContentVersion in cdlsViewMap which have same ContentDocumentId.
		  for(ContentVersion cdv: cdvList) {
			  if(cdlViewMap.containskey(cdv.ContentDocumentId)) {
				cdlView cdlv =  cdlViewMap.get(cdv.ContentDocumentId);
				cdlv.titleName = cdv.Title;
				cdlv.URL = cdv.Id;
				cdlv.FileExtension = cdv.FileExtension;
				cdlViewMap.put(cdv.ContentDocumentId,cdlv);
			  }
		  }

		//add cdlc(Category,Id and Title) to categoryMap which have same category.
		  for(cdlView cdlv: cdlViewMap.values()) {
			  if(docMap.containskey(cdlv.category)) {
				  docMap.get(cdlv.category).add(cdlv);
			  }
		  }
		  system.debug(docMap);






		return categoryMap;
    }






    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_DOCUMENTS;}









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



    public void showCategoryDetail() {

      List<Id> lsDocId = new List<Id>();
System.debug('Document ID: ' +idDocumentCategory);

      for (saDocuments__c doc : lsDocs) {
        if (doc.Id == idDocumentCategory) {
        	lCategoryName = doc.Category_large__c;
        	CategoryName =  doc.Category_small__c;
        	system.debug(lcategoryName);
        	system.debug(categoryName);
	        for (ContentDocumentLink cdl : doc.ContentDocumentLinks) {
	            lsDocId.add(cdl.ContentDocumentId);
	System.debug('Content Document ID: ' +cdl.ContentDocumentId);
	          }
	          break;
        }
      }

      lsContentVersion = new List<ContentVersion>();
      if (lsDocId != NULL && lsDocId.size() > 0) {
          lsContentVersion = [SELECT Id, ContentDocumentId, Title, FileType
                              FROM ContentVersion
                              WHERE ContentDocumentId IN :lsDocId
                              ORDER BY Title];
      }

System.debug('Nb files: ' +lsContentVersion.size());

    }

    public static Map<String, Map<String, String>> createSelectListMap(List<Schema.PicklistEntry> parentEntryList, List<Schema.PicklistEntry> childEntryList){

        List<Object> jsonStringList;
        Map<String, Map<String, String>> validForMap;
        Map<String, Integer> hexMap;
        Integer parentIndex;

        JSONGenerator gen;
        String jsonString;

        // hex=>intのMapを作成する
        hexMap = createHexMap();

        // スキーマの状態では取得できない項目があるため、JSONに変換する
        gen = JSON.createGenerator(true);
        gen.writeObject(childEntryList);
        jsonString = gen.getAsString();

        // JSON文字列のリストに変換する
        jsonStringList = (List<Object>)JSON.deserializeUntyped(jsonString);
        // 親選択リストのindexを初期化する
        parentIndex = 0;
        // Mapを作成する
        validForMap = new Map<String, Map<String, String>>();
        // 空白時の値を設定する
        validForMap.put('', new Map<String, String>());
        for(Schema.PicklistEntry parentEntry : parentEntryList){

            String parentValue;
            Integer testBit;

            // テスト用BITを作成する
            testBit = 8 >> (Math.mod(parentIndex, 4));

            // 親項目リストの値を取得する
            parentValue = parentEntry.getValue();
            // Mapに追加する
            validForMap.put(parentValue, new Map<String, String>());

            // 連動項目でループする
            for(Object obj : jsonStringList){

                Map<String, Object> schemaMap;
                String validFor;
                Blob b;
                String hexB;
                Integer bitIndex;
                String targetBit;
                Integer bitArray;

                // スキーマのMapを作成する
                schemaMap = (Map<String, Object>)obj;
                // 連動項目のビットセットを取得する
                validFor = String.valueOf(schemaMap.get('validFor'));
                // 存在しない場合は処理を行わない
                if(String.isEmpty(validFor)){

                    continue;
                }

                // 紐付けByte列を取得する
                b = EncodingUtil.base64Decode(validFor);
                // hexを文字列にする
                hexB = EncodingUtil.convertToHex(b);

                // hexBから親選択リストに対応するBITを含む文字のindexを取得する
                bitIndex = parentIndex / 4;
                // 文字を取得する
                targetBit = hexB.substring(bitIndex, bitIndex + 1);

                // 対象の文字が0である場合は処理を行わない
                if('0'.equals(targetBit)){

                    continue;
                }

                // 文字を数値にする
                bitArray = hexMap.get(targetBit);

                // 対応するBITが一致する場合、TRUE
                if((bitArray & testBit) != 0){

                    String childValue = String.valueOf(schemaMap.get('value'));
                    String childLabel = String.valueOf(schemaMap.get('label'));
                    validForMap.get(parentValue).put(childValue, childLabel);
                }
            }

            // 次のindexへ
            parentIndex++;
        }

        return validForMap;
    }

    /**
     * 0～fの値を数値で返すMapを作成する
     */
    private static  Map<String, Integer> createHexMap(){

        Map<String, Integer> hexMap;

        hexMap = new Map<String, Integer>();
        hexMap.put('0', 0);
        hexMap.put('1', 1);
        hexMap.put('2', 2);
        hexMap.put('3', 3);
        hexMap.put('4', 4);
        hexMap.put('5', 5);
        hexMap.put('6', 6);
        hexMap.put('7', 7);
        hexMap.put('8', 8);
        hexMap.put('9', 9);
        hexMap.put('A', 10);
        hexMap.put('B', 11);
        hexMap.put('C', 12);
        hexMap.put('D', 13);
        hexMap.put('E', 14);
        hexMap.put('F', 15);
        hexMap.put('a', 10);
        hexMap.put('b', 11);
        hexMap.put('c', 12);
        hexMap.put('d', 13);
        hexMap.put('e', 14);
        hexMap.put('f', 15);

        return hexMap;
    }

    //the class to display at VF.
    public class cdlView {
  	  public string titleName {get;set;}
  	  public string URL {get;set;}
  	  public string category {get;set;}
  	  public string FileExtension {get;set;}

    }


}