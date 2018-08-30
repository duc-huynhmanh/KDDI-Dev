public with sharing class auAdminResetPasswordCtrl {
	
	private static final Integer MAX_RECORD_SIZE = 10;
	public ApexPages.StandardSetController ssc {get; private set;}
	public List<User> userList {get; private set;}
	
	public String empNo {get; set;}
	public String empEmail {get; set;}
	public String empLastName {get; set;}
	public String empFirstName {get; set;}
	
	public String shopId {get; set;}
	
	public String seluserid {get; set;}

	public auAdminResetPasswordCtrl(ApexPages.Standardsetcontroller controller) {
		userList = new List<User>();
	}

	public void search() {
		try {
		ssc = getUserList();
		ssc.setPageSize(MAX_RECORD_SIZE);
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));
		}
	}
	
	public List<User> getUsers() {
		if (ssc != null) {
			userList = (List<User>)ssc.getRecords();
		}
		return userList;
	}
	
	public ApexPages.StandardSetController getUserList() {
		try {
			String queryStr = 'Select Id, Alias, LastName, FirstName, Email, UserRole.Name From User Where UserType != \'Guest\' And IsActive = true';
			List<String> clauses = new List<String>();
			
			if (String.IsNotBlank(empNo)) {
				clauses.add('(KDDIEmployeeId__c = \'' + EncodingUtil.urlEncode(empNo, 'UTF-8') + '\' OR ' +
							' SAUserId__c = \'' + EncodingUtil.urlEncode(empNo, 'UTF-8') + '\')');
			}
			if (String.IsNotBlank(empEmail)) {
				clauses.add('Email = \'' + EncodingUtil.urlEncode(empEmail, 'UTF-8') + '\'');
			}
			if (String.IsNotBlank(empLastName)) {
				clauses.add('LastName = \'' + EncodingUtil.urlEncode(empLastName, 'UTF-8') + '\'');
			}
			if (String.IsNotBlank(empFirstName)) {
				clauses.add('FirstName = \'' + EncodingUtil.urlEncode(empFirstName, 'UTF-8') + '\'');
			}
			if (String.IsNotBlank(shopId)) {
				clauses.add('Alias = \'' + EncodingUtil.urlEncode(shopId, 'UTF-8') + '\'');
			}
			String whereStr = ' ';
			for (Integer i = 0 ; i < clauses.size() ; i++ ) {
				whereStr += ' AND ' + clauses.get(i);
			}
			queryStr += whereStr;
			ssc = new ApexPages.StandardSetController(Database.getQueryLocator(queryStr));
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '例外エラーが発生しました。: ' + e.getMessage()));
		}
		return ssc;
	}
	
	public PageReference resetPassword() {
		try {
			if (String.IsBlank(seluserid)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'リセット対象を選択して下さい。'));
				return null;
			}
			User selectedUser = [Select Id, Alias From User Where Id = :seluserid];
			String tempPass = System.resetPassword(selectedUser.Id, false).getPassword();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ID:' + selectedUser.Alias + 'の仮パスワードは、「' + tempPass + '」です。'));
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '例外エラーが発生しました。: ' + e.getMessage()));
		}
		return null;
	}
	
	public void selectcon() {
	    seluserid = System.currentPagereference().getParameters().get('uid');
	}
	
	public PageReference next() {
		ssc.next();
		userList = (List<User>)ssc.getRecords();
		return null;
	}
	
    public Boolean hasNext {
        get {
            if (ssc != null) {
                return ssc.getHasNext();
            } else {
                return false;
            }
        }
        set;
    }
	
	public PageReference previous() {
		ssc.previous();
		userList = (List<User>)ssc.getRecords();
		return null;
	}
	
    public Boolean hasPrevious {
        get {
            if (ssc != null) {
                return ssc.getHasPrevious();
            } else {
                return false;
            }
        }
        set; 
    }
}