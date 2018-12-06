public with sharing class kdKnowledgeCSVFileExportingCtrl {
	public String sTitle {get; set;}
	public List<List<String>> lslsRow {get;set;}
	private String orderby;
	private List<String> kdKnowledgeIds;
	private String inClause;
	

	public kdKnowledgeCSVFileExportingCtrl() {
		createFileName();
		queryData();
	}

	private void createFileName(){
		String csvType = Apexpages.currentPage().getParameters().get('type');
		String fileName = '';
		if(csvType == '1'){
        	fileName = '利用状況';
        	//head row
			sTitle = '"タブ名称","社内発表会、共有会など/販売事例","テーマ","タイトル","記事ID","バージョン","ステータス","動画",'+
			'"作成者所属部門1","作成者所属部門2","作成者所属部門3","作成者所属部門コード1","作成者所属部門コード2",'+
			'"作成者所属部門コード3","作成者氏名","作成者社員番号","公開日時","更新日時","閲覧者所属部門1","閲覧者所属部門2",'+
			'"閲覧者所属部門3","閲覧者所属部門コード1","閲覧者所属部門コード2","閲覧者所属部門コード3","閲覧者氏名","閲覧者社員番号",'+
			'"閲覧日","閲覧時間","PC/Tab"';
        } else if(csvType == '2') {
        	fileName = 'いいね・まねした';
        	//head row
			sTitle = '"テーマ","タイトル","作成者所属部門１","作成者所属部門２","作成者氏名","いいね！","いいね！コメント","まねした！",' +
			'"まねした！コメント１","まねした！コメント２","まねした！コメント３","まねした！コメント４","まねした！コメント５","氏名","所属１",' +
			'"所属２","社員番号","記載日時"';
        }
		filename = 	filename + '_' + Datetime.now().format('yyyyMMdd') + '.csv';
		Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="";filename*=UTF-8\'\'' + EncodingUtil.urlEncode(fileName, 'UTF-8'));
	}

	private String createQueryString(){
		String queryStr = 'SELECT Title__c, Description__c, (SELECT Name From Attachments) FROM kdKnowledge__c';
		String whereStr = Apexpages.currentPage().getParameters().get('where');
		
		if(!String.isBlank(whereStr)){
			whereStr = EncodingUtil.urlDecode(whereStr, 'UTF-8');
			queryStr += whereStr;
		}
		
		return queryStr;
	}

	private void queryData(){
		String queryStr = createQueryString();
		String filter = Apexpages.currentPage().getParameters().get('filter');
		List<kdKnowledge__c> listK = new List<kdKnowledge__c>();
		if (String.isBlank(filter)) {
            listK = Database.query(queryStr);
        } else {
            for (kdKnowledge__c kdKnowledge : Database.query(queryStr)) {
                Boolean fFilterFilled = false;
                if ((kdKnowledge.Title__c != NULL && kdKnowledge.Title__c.containsIgnoreCase(filter)) || 
                    (kdKnowledge.Description__c != NULL && kdKnowledge.Description__c.containsIgnoreCase(filter))) {
                    fFilterFilled = true;
                } else {
                    for (Attachment att : kdKnowledge.Attachments) {
                        if ((att.Name != NULL && att.Name.containsIgnoreCase(filter))) {
                            fFilterFilled = true;
                            break;
                        }
                    }
                }
                if (fFilterFilled) {
                    listK.add(kdKnowledge);                   
                }
            }
            system.debug('listK: ' + listK);
        }

        if(!listK.isEmpty()){
        	orderby = Apexpages.currentPage().getParameters().get('orderby');
			if(!String.isBlank(orderby)){
				orderby = 'kdKnowledge__r.' + orderby;
			} else {
				orderby = 'kdKnowledge__r.Id';
			}
			system.debug('orderby: ' + orderby);
			kdKnowledgeIds = new List<String>();
			for(kdKnowledge__c k : listK) {
				kdKnowledgeIds.add(k.Id);
			}
			inClause = '(\'' + String.join(kdKnowledgeIds,'\',\'') + '\')';
        	String csvType = Apexpages.currentPage().getParameters().get('type');
        	if(csvType == '1'){
        		String queryDetail = 'SELECT kdKnowledge__c, kdKnowledge__r.Thema__c, kdKnowledge__r.Title__c, ' +
					'kdKnowledge__r.Status__c, kdKnowledge__r.HasMovie__c, kdKnowledge__r.CreatedBy__r.DisplayedUsernameFormula__c, ' +
					'kdKnowledge__r.CreatedBy__r.KDDIEmployeeId__c, kdKnowledge__r.PostTime__c, kdKnowledge__r.LastModifiedDateFormula__c, ' +
					'User__r.DisplayedUsernameFormula__c, User__r.KDDIEmployeeId__c, User__r.CreatedDate ' + 
					'FROM kdKnowledgeDetail__c WHERE kdKnowledge__c IN ' + inClause + ' AND IsView__c = true ORDER BY ' + orderby;
        		lslsRow = createCsvData1(queryDetail);
        	} else if(csvType == '2') {
        		String queryDetail = 'SELECT kdKnowledge__r.Thema__c, kdKnowledge__r.Title__c, IsLike__c, IsCopy__c, ' +
					'CommentLike__c, CommentCopy__c, CommentCopy1__c, CommentCopy2__c, CommentCopy3__c, CommentCopy4__c, kdKnowledge__r.CreatedBy__r.DisplayedUsernameFormula__c, ' +
					'User__r.DisplayedUsernameFormula__c, User__r.KDDIEmployeeId__c, CreatedDate ' +
					'FROM kdKnowledgeDetail__c WHERE kdKnowledge__c IN ' + inClause + ' AND (IsLike__c = True OR IsCopy__c = True) ORDER BY ' + orderby;
        		lslsRow = createCsvData2(queryDetail);
        	}
        }
	}

	//利用状況
	@ReadOnly @RemoteAction public static List<List<String>> createCsvData1(String queryDetail){
		system.debug('queryDetail: ' + queryDetail);
		List<kdKnowledgeDetail__c> listDetail = Database.query(queryDetail);
		system.debug('listDetail: ' + listDetail);
		Map<String, String> themaMap = new Map<String, String>();
        for (Schema.PicklistEntry f : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
            themaMap.put(f.getValue(), f.getLabel());
        }
		
		List<List<String>> lslsRow = new List<List<String>>();
		List<String> lsRow = new List<String>();
		for (kdKnowledgeDetail__c d : listDetail) {
			if(lsRow.size() >= 1000) {
				lslsRow.add(lsRow);
	            lsRow = new List<String>();
			}
			String csvRow = '"営業ナレッジ","","' + themaMap.get(d.kdKnowledge__r.Thema__c) + '","' + d.kdKnowledge__r.Title__c + '","' + d.kdKnowledge__c + 
			'","","' + ((d.kdKnowledge__r.Status__c == 'Saved') ? '保存' : '一時保存') + '","' + (d.kdKnowledge__r.HasMovie__c ? '動画有り' : '動画無し') + 
			'","","","","","","","' + 
			d.kdKnowledge__r.CreatedBy__r.DisplayedUsernameFormula__c + '","' + ((!String.isBlank(d.kdKnowledge__r.CreatedBy__r.KDDIEmployeeId__c)) ? d.kdKnowledge__r.CreatedBy__r.KDDIEmployeeId__c : '') +
			'","' + d.kdKnowledge__r.PostTime__c + '","' + d.kdKnowledge__r.LastModifiedDateFormula__c +
			'","","","","","","","' +
			d.User__r.DisplayedUsernameFormula__c + '","' + ((!String.isBlank(d.User__r.KDDIEmployeeId__c)) ? d.User__r.KDDIEmployeeId__c : '') + '","' + d.User__r.CreatedDate.format('yyyy-MM-dd') +
			'","' + d.User__r.CreatedDate.format('HH:mm:ss') + '",""';
			lsRow.add(csvRow);
		}
		lslsRow.add(lsRow);
		return lslsRow;
	}
	//いいね・まねした
	@ReadOnly @RemoteAction public static List<List<String>> createCsvData2(String queryDetail){
		system.debug('queryDetail: ' + queryDetail);
		List<kdKnowledgeDetail__c> listDetail = Database.query(queryDetail);
		system.debug('listDetail: ' + listDetail);
		Map<String, String> themaMap = new Map<String, String>();
        for (Schema.PicklistEntry f : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
            themaMap.put(f.getValue(), f.getLabel());
        }
		
		List<List<String>> lslsRow = new List<List<String>>();
		List<String> lsRow = new List<String>();
		for (kdKnowledgeDetail__c d : listDetail) {
			if(lsRow.size() >= 1000) {
				lslsRow.add(lsRow);
	            lsRow = new List<String>();
			}
			String csvRow = '"' + themaMap.get(d.kdKnowledge__r.Thema__c) + '","' + d.kdKnowledge__r.Title__c + '","","","' + 
			d.kdKnowledge__r.CreatedBy__r.DisplayedUsernameFormula__c + '","' + (d.IsLike__c ? '1' : '0') + '","' +
			((d.IsLike__c && !String.isBlank(d.CommentLike__c)) ? d.CommentLike__c : '') + '","' +
			(d.IsCopy__c ? '1' : '0') + '","' + 
			((d.IsCopy__c && !String.isBlank(d.CommentCopy__c)) ? d.CommentCopy__c : '') + '","' +
			((d.IsCopy__c && !String.isBlank(d.CommentCopy1__c)) ? d.CommentCopy1__c : '') + '","' +
			((d.IsCopy__c && !String.isBlank(d.CommentCopy2__c)) ? d.CommentCopy2__c : '') + '","' + 
			((d.IsCopy__c && !String.isBlank(d.CommentCopy3__c)) ? d.CommentCopy3__c : '') + '","' +
			((d.IsCopy__c && !String.isBlank(d.CommentCopy4__c)) ? d.CommentCopy4__c : '') + '","' + d.User__r.DisplayedUsernameFormula__c + '","","","' + 
			((!String.isBlank(d.User__r.KDDIEmployeeId__c)) ? d.User__r.KDDIEmployeeId__c : '') + '","' +
			d.CreatedDate + '"';
			lsRow.add(csvRow);
		}
		lslsRow.add(lsRow);
		return lslsRow;
	}
}