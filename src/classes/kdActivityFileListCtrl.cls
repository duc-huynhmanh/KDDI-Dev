/**
* @author Kazuki Kobayashi
* @date 2019/5/13
* @description the controller class to display document at CCP+ library page
*/

public with sharing class kdActivityFileListCtrl {
public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_FILE_LIST;}

  public kdActivityFileListCtrl () {}

  /**
  * @description get values of picklist which is specified at param.
  * @param sObjName:the name of Object
  * @param fieldName:the name of field which have picklist
  * @return the value list of picklist
  */
  public List<Schema.PicklistEntry> getPicklist(String sObjName, String fieldName){
      List<Schema.PicklistEntry> pickList;
      Schema.SObjectType sObjType = (Schema.SObjectType) Schema.getGlobalDescribe().get(sObjName);
      if(sObjType != null){
          Map<String, Schema.SObjectField> fieldmap = sObjType.getDescribe().fields.getMap();
          Schema.SObjectField f = (Schema.SObjectField) fieldmap.get(fieldName);
          if(f != null){
              Schema.DescribeFieldResult r = f.getDescribe();
              pickList = r.getPicklistValues();
          }
      }
      return pickList;
  }
  /**
  * @description get values of picklist by getPicklist method and chage to vabels
  * @return the label list of picklist
  */
  public List<String> getLabelList() {
	    List<Schema.PicklistEntry> labels = getPicklist('saDocuments__c', 'Category_CCP__c');
	    List<String> labelList = new List<String>();
	    for(Schema.PicklistEntry LV :labels){
	        labelList.add(LV.getLabel());
	    }
	    system.debug(labelList);
	    return labelList;
  }

  public Map<String,List<cdlView>> getCategoryMap(){
	  Map<String, List<cdlView>> categoryMap = new Map<String, List<cdlView>>();
	  List<String> categoryNameList = getLabelList();
	  for(String categoryName :categoryNameList){
		  //make new list which have category name as key and put in categoryMap.
		  categoryMap.put(categoryName, new List<cdlView>());
	  }

	  List<saDocuments__c> lsDocs2 = [SELECT tolabel(Category_CCP__c),
	                                 (SELECT Id, ContentDocumentId, contentDocument.title FROM ContentDocumentLinks
	                                		 ORDER BY ContentDocument.createdDate DESC LIMIT 1)
	                                 FROM saDocuments__c WHERE RecordType.DeveloperName = 'CCP'
	                                 ORDER BY SortNo__c NULLS FIRST];

	  //put ContentDocumentId and categoryName(Category_CCP__c) in cdlViewMap.
	  Map<String, cdlView> cdlViewMap = new Map<String, cdlView>();
	  for(saDocuments__c doc :lsDocs2) {
		  for(ContentDocumentLink cdl :doc.ContentDocumentLinks) {
			  cdlView cdlv = new cdlView();
			  cdlv.category = doc.Category_CCP__c;
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
		  if(categoryMap.containskey(cdlv.category)) {
			 categoryMap.get(cdlv.category).add(cdlv);
		  }
	  }

	 //Check debug
	 Set<String> mapSet =  categoryMap.keySet();
	 for(String m: mapSet) {
		 system.debug('カテゴリー名='+m);
		 categoryMap.get(m);
		 for(cdlView cdl: categoryMap.get(m)) {
			 system.debug(cdl.titleName);
			 system.debug(cdl.URL);
			 system.debug(cdl.category);
		 }
	 }
	  return categoryMap;
  }

  //the class to display at VF.
  public class cdlView {
	  public string titleName {get;set;}
	  public string URL {get;set;}
	  public string category {get;set;}
	  public string FileExtension {get;set;}

  }

}