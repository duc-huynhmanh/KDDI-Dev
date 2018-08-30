global with sharing class auHearingReplyCSVFileExportingCtrl {
	public String fileName{get; set;}
	public Boolean isProcess{get;set;}
	public String sTitle {get; set;}
    Public List<List<String>> lslsRow{get;set;}

    private User currentUser = [SELECT Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    private Boolean isUserProfileEvolva(){
        return currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
    }

    public List<UserRole> getEvolvaChildRole(List<UserRole> lsRolesMemo, String parentRoleDeveloperName, boolean includeParentRole, boolean includeAllDescendants) {
      String shitenRole = parentRoleDeveloperName;
      List<UserRole> lsRoles = NULL;
      id idParentRole = NULL;
      List<UserRole> lsUserRoleReturn = new List<UserRole>();

      //Get the list of all the Roles
      lsRoles = [SELECT Id, DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal'
                   ORDER BY DeveloperName];
      
      //Get Shiten Role Id
      for (UserRole pur : lsRoles) {
        if (pur.DeveloperName == shitenRole) {
          idParentRole = pur.Id;
          break;
        }
      }

      //Get direct Child of the Shiten Role
      if (idParentRole != NULL) {
        for (UserRole ur : lsRoles) {
          if (ur.ParentRoleId == idParentRole) {
            Id mainRoleId=ur.Id;
            //For each of those role, get the direct Child
            for (UserRole sur : lsRoles) {
                if (sur.ParentRoleId == mainRoleId) {
                    lsUserRoleReturn.add(sur);
                }
            }
          }
        }       
      }

      return lsUserRoleReturn;
    }

    public List<SelectOption> getShishaOptions() {
      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));

      if(isUserProfileEvolva()){
          for (UserRole ur : getEvolvaChildRole(NULL, auConstantCmn.ROLE_CODE_EVOLVA_SHITEN, false, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
          }
      }else{
          for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
          }
      }
      return lsReturn;
    }

    public String getShisha(String code) {
    	if (String.isBlank(code)) return '';
    	if (code == 'EKEV01') return '営業統括本部';
        for (SelectOption so : getShishaOptions()) {
            if (so.getValue() == code) {
            	return so.getLabel();
            }
        }
      return '';
    }

    public String getShiten(String code){
    	if (String.isBlank(code)) return '';
        for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, true)) {
            if(ur.DeveloperName == code) return ur.Name;
        }
        return '';
    }

	public auHearingReplyCSVFileExportingCtrl() {
		String inquyryId = ApexPages.currentPage().getParameters().get('exportId');
		List<saInquiryDetail__c> questions = new List<saInquiryDetail__c>();
		Map<Id, String[]> mapReplies = new Map<Id, String[]>();
		if(!String.isBlank(inquyryId)){
			for(saInquiry__c inq : [SELECT ReportName__c, RegionalOfficeCode__c, BranchCode__c, CreatedBy.Name, ValidFromDatetime__c, ValidToDatetime__c, IsValid__c, LastModifiedDate, LastModifiedBy.Name,
				(SELECT QuestionLabel__c, AnswerType__c, NumberPossibleReplies__c, Reply01Label__c, 
					Reply02Label__c, Reply03Label__c,  Reply04Label__c,  Reply05Label__c, Reply06Label__c,  
					Reply07Label__c, Reply08Label__c,  Reply09Label__c,  Reply10Label__c, Reply11Label__c, 
					Reply12Label__c, Reply13Label__c,  Reply14Label__c,  Reply15Label__c, Reply16Label__c,  
					Reply17Label__c, Reply18Label__c,  Reply19Label__c,  Reply20Label__c, Reply21Label__c, 
					Reply22Label__c, Reply23Label__c,  Reply24Label__c,  Reply25Label__c FROM saInquiryDetail_md__r ORDER BY SortNo__c, Name)
				FROM saInquiry__c WHERE Id = :inquyryId]) {
				Map<Id,saInquiryDetail__c> questionMap = new Map<Id, saInquiryDetail__c>(inq.saInquiryDetail_md__r);
				questions = questionMap.values();
				Set<Id> questionIds = questionMap.keySet();
				/*for(saInquiryDetail__c q : inq.saInquiryDetail_md__r) {
					questions.add(q);
				}*/
				for(saInquiryDetail__c detailInq : inq.saInquiryDetail_md__r) {
					if(detailInq.AnswerType__c == 'RADIO_BUTTON' || detailInq.AnswerType__c == 'CHECKBOX'){
						String[] answers = new String[25];
						for(Integer i = 0; i<25; i++){
							answers[i] = (String) detailInq.get('Reply' + String.valueOf(i+1).leftPad(2, '0') + 'Label__c');
						}
						mapReplies.put(detailInq.Id, answers);
					}
				}

				//system.debug('questions: ' + questions);

				//head row
				sTitle = '"支社","支店","作成者","ヒアリング件名","ヒアリング開始日","ヒアリング終了日","運用中フラグ","最終更新日","最終更新者","序列コード","組織名","社員番号","報告者名"';
				for (saInquiryDetail__c q : questions) {
					sTitle += ',"' + q.QuestionLabel__c + '"';
				}
				
				fileName = 'Hearing_';
				fileName += String.isBlank(inq.ReportName__c) ? String.valueOf(Date.today()) : inq.ReportName__c.remove('/');
				//system.debug('fileName: ' + fileName);
				String strFrom = ApexPages.currentPage().getParameters().get('from');
        		String strTo = ApexPages.currentPage().getParameters().get('to');
        		if(!String.isBlank(strFrom)){
        			fileName += '_From' + strFrom.replace('/', '-');
        		}
        		if(!String.isBlank(strTo)){
        			fileName += '_To' + strTo.replace('/', '-');
        		}
        		fileName += '.csv';
        		String validFrom = inq.ValidFromDatetime__c == null ? 'null' : inq.ValidFromDatetime__c.format('yyyy-MM-dd HH:mm:ss');
        		String validTo = inq.ValidToDatetime__c == null ? 'null' : inq.ValidToDatetime__c.format('yyyy-MM-dd HH:mm:ss');
        		String shisha = getShisha(inq.RegionalOfficeCode__c);
        		String shiten = getShiten(inq.BranchCode__c);
        		String createBy = inq.CreatedBy.Name;
        		String reportName = inq.ReportName__c;
        		Boolean isValid = inq.IsValid__c;
        		String lastModifiedDate = inq.LastModifiedDate.format('yyyy/MM/dd');
        		String lastModifiedBy = inq.LastModifiedBy.Name;

				lslsRow = createCSVFile(inquyryId, questionIds, reportName, shisha, shiten, createBy, validFrom, validTo, isValid, lastModifiedDate, lastModifiedBy, mapReplies);
				isProcess = lslsRow != null;
				
				if(isProcess){
					Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="' + EncodingUtil.urlEncode(fileName, 'UTF-8') + '"');
				} else {
					sTitle = '';
					fileName = '';
				}
			}
		}
	}

	//@ReadOnly @RemoteAction global static List<List<String>> createCSVFile(String inquyryId, List<saInquiryDetail__c> questions){
	@ReadOnly @RemoteAction global static List<List<String>> createCSVFile(String inquyryId, Set<Id> questionIds, String reportName, String shisha, String shiten, String createBy, String validFrom, String validTo, Boolean isValid, String lastModifiedDate, String lastModifiedBy, Map<Id, String[]> mapReplies){
        List<List<String>> lslsRow = new List<List<String>>();
		Map<String, Integer> questionOrders = new Map<String, Integer>();
		Integer questionCount = 0;
		for (Id q : questionIds) {
			questionOrders.put(q, questionCount);
			questionCount++;
		}

		//system.debug('detailReplies: ' + detailReplies);
		String previousRow = '';
		Integer previousQuestionIndex = questionCount - 2;
		Integer questionIndex = questionCount - 1;
		String csvRow = '';
        List<String> lsRow = new List<String>();
        integer iSize = 0;

        // Get Date From and Date To
        Date dDateMin = Date.newInstance(1900, 1, 1);
        Date dDateMax = Date.newInstance(9999, 12, 31);

        String strFrom = ApexPages.currentPage().getParameters().get('from');
        String strTo = ApexPages.currentPage().getParameters().get('to');
        
        if(!String.isBlank(strFrom)) {
        	dDateMin = Date.newInstance(Integer.valueOf(strFrom.substring(0,4)), Integer.valueOf(strFrom.substring(5,7)), Integer.valueOf(strFrom.substring(8,10)));
        }
        if(!String.isBlank(strTo)) {
        	dDateMax = Date.newInstance(Integer.valueOf(strTo.substring(0,4)), Integer.valueOf(strTo.substring(5,7)), Integer.valueOf(strTo.substring(8,10)));
        }

		//content rows
		for(saInquiryReplyDetail__c reply : [SELECT 
			saInquiryReply__r.DailyReportDate__c,
			saInquiryReply__r.User__r.UserRole.DeveloperName,
			saInquiryReply__r.User__r.UserRole.Name,
			saInquiryReply__r.saBusinessLocation__r.Code__c,
			saInquiryReply__r.saBusinessLocation__r.BusinessLocationName__c,
			saInquiryReply__r.saBusinessLocation__r.AgencyCode__c,
			saInquiryReply__r.saBusinessLocation__r.AgencyName__c,
			saInquiryReply__r.saBusinessLocation__r.SupervisorCode__c,
			saInquiryReply__r.saBusinessLocation__r.SupervisorName__c,
			saInquiryReply__r.User__r.KDDIEmployeeId__c,
			saInquiryReply__r.User__r.DisplayedUsernameFormula__c,

			saInquiryDetail__r.AnswerType__c,
			saInquiryDetail__r.NumberPossibleReplies__c,

			CreatedDate,
			ReplyCheckbox01__c,
			ReplyCheckbox02__c,
			ReplyCheckbox03__c,
			ReplyCheckbox04__c,
			ReplyCheckbox05__c,
			ReplyCheckbox06__c,
			ReplyCheckbox07__c,
			ReplyCheckbox08__c,
			ReplyCheckbox09__c,
			ReplyCheckbox10__c,
			ReplyCheckbox11__c,
			ReplyCheckbox12__c,
			ReplyCheckbox13__c,
			ReplyCheckbox14__c,
			ReplyCheckbox15__c,
			ReplyCheckbox16__c,
			ReplyCheckbox17__c,
			ReplyCheckbox18__c,
			ReplyCheckbox19__c,
			ReplyCheckbox20__c,
			ReplyCheckbox21__c,
			ReplyCheckbox22__c,
			ReplyCheckbox23__c,
			ReplyCheckbox24__c,
			ReplyCheckbox25__c,
			ReplyDateEnd__c, 
			ReplyDateStart__c, 
			ReplyDecimal__c,
			ReplyNumber__c,
			ReplyRadioButton__c,
			ReplyText__c
			
			FROM saInquiryReplyDetail__c
			WHERE saInquiryDetail__c IN :questionIds
			AND saInquiryReply__r.saInquiry__c = :inquyryId
			AND saInquiryReply__r.Status__c = :saConstantCmn.SA_REPORT_REPLY_STATUS_REPLYSENT
			AND saInquiryReply__r.saInquiry__r.Type__c = 'AU_HEARING'
			AND
			(
				saInquiryReply__r.ReplyDatetime__c = NULL 
				OR 
				(
					DAY_ONLY(convertTimezone(saInquiryReply__r.ReplyDatetime__c)) >= :dDateMin 
					AND 
					DAY_ONLY(convertTimezone(saInquiryReply__r.ReplyDatetime__c)) <= :dDateMax
				)
			)
			
			ORDER BY saInquiryReply__c, saInquiryDetail__r.SortNo__c, saInquiryDetail__r.Name]) {
			//system.debug('Limits.getCpuTime(): ' + Limits.getCpuTime());
			if(Limits.getCpuTime() >= 9000) {
			//if(Limits.getCpuTime() >= 10) {
				return null;
			}
			//if meet a new saInquiryReply__c id, then start new row, in other cases, just adding answers to row
			if(String.valueOf(reply.saInquiryReply__r.Id) != previousRow) {
				previousRow = String.valueOf(reply.saInquiryReply__r.Id);
				//filling in all questions which are not answered yet
				//the reason put it here because we only know it finished a row when met a new saInquiryReply__c Id
				for(Integer i = questionIndex; i < questionCount-1; i++){
					csvRow += ',""';
				}
				//add content row into result

				if (csvRow.length() > 0) {
		            lsRow.add(csvRow);            
	    	        iSize += 1;					
				}

	            if (iSize == 1000) {
	                lslsRow.add(lsRow);
	                lsRow = new List<String>();
	                iSize = 0;
	            }
				
				//start new row
				//支社
				csvRow = '"' + shisha + '"';
				//支店
				csvRow += ',"' + shiten + '"';
				//作成者
				csvRow += ',"' + createBy + '"';
				//ヒアリング件名
				csvRow += ',"' + reportName + '"';
				//ヒアリング開始日
				csvRow += ',"' + validFrom + '"';
				//ヒアリング終了日
				csvRow += ',"' + validTo + '"';
				//運用中フラグ
				csvRow += ',"' + (isValid ? '○' : '') + '"';
				//最終更新日
				csvRow += ',"' + lastModifiedDate + '"';
				//最終更新者
				csvRow += ',"' + lastModifiedBy + '"';
				//ユーザー情報
				//序列コード
				csvRow += ',"' + reply.saInquiryReply__r.User__r.UserRole.DeveloperName + '"';
				//組織名
				csvRow += ',"' + reply.saInquiryReply__r.User__r.UserRole.Name + '"';
				//社員番号
				csvRow += ',"' + reply.saInquiryReply__r.User__r.KDDIEmployeeId__c + '"';
				//報告者名
				csvRow += ',"' + reply.saInquiryReply__r.User__r.DisplayedUsernameFormula__c + '"';
				previousQuestionIndex = -1;
			}

			//adding answer
			questionIndex = questionOrders.get(reply.saInquiryDetail__r.Id);
			
			//filling in all previous questions which are not answered yet
			for(Integer i = previousQuestionIndex + 1; i < questionIndex; i++) {
				csvRow += ',""';
			}
			previousQuestionIndex = questionIndex;

			if(reply.saInquiryDetail__r.AnswerType__c == 'CHECKBOX') {
				csvRow += ',"';
				for(Integer i = 0; i < Integer.valueOf(reply.saInquiryDetail__r.NumberPossibleReplies__c); i++) {
					List<String> param = new List<String>{String.valueOf(i+1).leftPad(2, '0')};
					if((Boolean)reply.get(String.format('ReplyCheckbox{0}__c', param))){
						//csvRow += (String)reply.saInquiryDetail__r.get(String.format('Reply{0}Label__c', param)) + ', ';
						csvRow += ((String[])mapReplies.get(reply.saInquiryDetail__r.Id))[i] + ', ';
					}
				}
				csvRow = csvRow.removeEnd(', ');
				csvRow += '"';
			} else if (reply.saInquiryDetail__r.AnswerType__c == 'TEXT'){
				csvRow += ',"' + reply.ReplyText__c + '"';
			} else if (reply.saInquiryDetail__r.AnswerType__c == 'NUMBER'){
				csvRow += ',"' + reply.ReplyNumber__c + '"';
			} else if (reply.saInquiryDetail__r.AnswerType__c == 'DECIMAL'){
				csvRow += ',"' + reply.ReplyDecimal__c + '"';
			} else if (reply.saInquiryDetail__r.AnswerType__c == 'RADIO_BUTTON'){
				if (String.isBlank(reply.ReplyRadioButton__c)) {
					//返事無し;
					csvRow += ',""';
				} else {
					/*List<String> param = new List<String>{reply.ReplyRadioButton__c.subString(6)};
					csvRow += ',"' + (String)reply.saInquiryDetail__r.get(String.format('Reply{0}Label__c', param)) + '"';*/
					Integer indexAnswer = Integer.valueOf(reply.ReplyRadioButton__c.subString(6));
					csvRow += ',"' + ((String[])mapReplies.get(reply.saInquiryDetail__r.Id))[indexAnswer-1] + '"';
				}
			} else if (reply.saInquiryDetail__r.AnswerType__c == 'DATE'){
				Date d = reply.ReplyDateStart__c;
				csvRow += d == null ? ',""' : ',"' + d.year() + '-' + String.valueOf(d.month()).leftPad(2, '0') + '-' + String.valueOf(d.day()).leftPad(2, '0') + '"';
				//csvRow += ',"' + reply.ReplyDateStart__c + '"';
			} else if (reply.saInquiryDetail__r.AnswerType__c == 'PERIOD'){
				Date d1 = reply.ReplyDateStart__c;
				String strD1 = d1 == null ? 'null' : d1.year() + '-' + String.valueOf(d1.month()).leftPad(2, '0') + '-' + String.valueOf(d1.day()).leftPad(2, '0');
				Date d2 = reply.ReplyDateEnd__c;
				String strD2 = d2 == null ? 'null' : d2.year() + '-' + String.valueOf(d2.month()).leftPad(2, '0') + '-' + String.valueOf(d2.day()).leftPad(2, '0');
				
				csvRow += ',"' + strD1 + ' ~ ' + strD2 + '"';
			} else if (reply.saInquiryDetail__r.AnswerType__c == 'LABEL'){
				csvRow += ',""';
			}
		}

		for(Integer i = questionIndex; i < questionCount-1; i++){
			csvRow += ',""';
		}

		/*if (csvRow.length() > 0) {
            lsRow.add(csvRow);            
            lslsRow.add(lsRow);
		}*/
		if (csvRow.length() > 0) {
			if(iSize < 1000) {
				lsRow.add(csvRow);
			} else {
				lslsRow.add(lsRow);
				lsRow = new List<String>();
				lsRow.add(csvRow);
			}
            lslsRow.add(lsRow);
		}

		return lslsRow;
	}
}