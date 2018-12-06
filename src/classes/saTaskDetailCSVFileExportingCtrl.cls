public with sharing class saTaskDetailCSVFileExportingCtrl {
	public String sTitle {get; set;}
	public List<List<String>> lslsRow {get;set;}
	private String orderby;
	private List<String> kdKnowledgeIds;
	private String inClause;
	

	public saTaskDetailCSVFileExportingCtrl() {
		sTitle = '"発信元支社","発信元支店","作成者","ToDo件名","ToDo開始日","ToDo終了日","運用中フラグ","最終更新日","最終更新者","序列コード","組織名","社員番号","報告者名"';
		String messageId = Apexpages.currentPage().getParameters().get('id');
		String queryStr = 'SELECT RegionalOfficeCode__c, BranchCode__c, CreatedBy.Name, Title__c, PublishedDateFormula__c, DeadlineDateFormula__c, IsPublished__c, LastModifiedDate, LastModifiedBy.Name, Description__c FROM saMessage__c WHERE Id = \'' +  String.escapeSingleQuotes(messageId) + '\'';
		
		for (saMessage__c m : Database.query(queryStr)){
			String fileName = '';
       		fileName = 'ToDo_';
       		String tit = (m.Title__c == null ? Datetime.now().format('yyyyMMdd') : m.Title__c.replace('/', '-'));
			filename = 	filename + tit + '.csv';
			Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="";filename*=UTF-8\'\'' + EncodingUtil.urlEncode(fileName, 'UTF-8'));
			sTitle += (',"' + (m.Description__c == null ? '' : m.Description__c) + '"');
        	String queryDetail = 'SELECT User__r.UserRole.DeveloperName, User__r.UserRole.Name, User__r.KDDIEmployeeId__c, User__r.DisplayedUsernameFormula__c, ReplyComment__c ' + 
				'FROM saMessageDetail__c WHERE Type__c = \'DONE\' AND saMessage__c = \'' +  String.escapeSingleQuotes(messageId) + '\'';
			String shisha = '';
			String shiten = '';
			for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, true)) {
       		    if(ur.DeveloperName == m.RegionalOfficeCode__c){
       		    	shisha = ur.Name;
       		    }
       		    if(ur.DeveloperName == m.BranchCode__c){
       		    	shiten = ur.Name;
       		    }
       		    if(!String.isBlank(shisha) && !String.isBlank(shiten)) {
       		    	break;
       		    }
       		}

       		Date fromDate = m.PublishedDateFormula__c;
        	Date toDate = m.DeadlineDateFormula__c;
        	String fromDt = fromDate != null ? datetime.newInstance(fromDate.year(), fromDate.month(), fromDate.day()).format('yyyy/MM/dd') : '';
        	String toDt = toDate != null ? datetime.newInstance(toDate.year(), toDate.month(), toDate.day()).format('yyyy/MM/dd') : '';		

        	lslsRow = createCsvData(queryDetail, shisha, shiten, m.CreatedBy.Name, m.Title__c, fromDt, toDt, m.IsPublished__c, m.LastModifiedDate.format('yyyy/MM/dd'), m.LastModifiedBy.Name);
        }
	}

	//利用状況
	@ReadOnly @RemoteAction public static List<List<String>> createCsvData(String queryDetail, String shisha, 
		String shiten, String createBy, String title, String dateFrom, String dateTo, Boolean isPublic, String lastModifiedDate, String lastModifiedBy){
		List<saMessageDetail__c> listDetail = Database.query(queryDetail);
		List<List<String>> lslsRow = new List<List<String>>();
		List<String> lsRow = new List<String>();
		for (saMessageDetail__c d : listDetail) {
			if(lsRow.size() >= 1000) {
				lslsRow.add(lsRow);
	            lsRow = new List<String>();
			}
			String csvRow = '"' + shisha + '","' + shiten + '","' + createBy + '","' + title + '","' + dateFrom + '","' + dateTo + '","' +
			(isPublic ? '○' : '') + '","' + lastModifiedDate + '","' + lastModifiedBy + '","' + d.User__r.UserRole.DeveloperName + 
			'","' + d.User__r.UserRole.Name + '","' + d.User__r.KDDIEmployeeId__c + '","' + d.User__r.DisplayedUsernameFormula__c + '","' + (d.ReplyComment__c == null ? '' : d.ReplyComment__c) + '"';
			
			lsRow.add(csvRow);
		}
		lslsRow.add(lsRow);
		return lslsRow;
	}
}