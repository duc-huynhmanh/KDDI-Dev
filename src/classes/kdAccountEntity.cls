global class kdAccountEntity implements Comparable {
	private String orderBy;
    public String accId {get;set;}
    public String partnerCode {get;set;}
    public String partnerName {get;set;}
    public String corpCode {get;set;}
    public String corpName {get;set;}
    public String regional {get;set;}
    public String branch {get;set;}
    public String salesman {get;set;}
    public String attachmentId {get;set;}
    public Boolean hasAccess {get;set;}
    
    // Constructor
    public kdAccountEntity(String ob) {
        orderBy = ob;
    }
    public kdAccountEntity() {
    }
    
    // Implement the compareTo() method
    global Integer compareTo(Object compareTo) {
        kdAccountEntity compareToEmp = (kdAccountEntity)compareTo;
        switch on orderBy {
		    when 'partnerCode' {
		        if (partnerCode == compareToEmp.partnerCode) return 0;
        		if (partnerCode > compareToEmp.partnerCode) return 1;
        		return -1; 
		    }	
		    when 'partnerName' {
		        if (partnerName == compareToEmp.partnerName) return 0;
        		if (partnerName > compareToEmp.partnerName) return 1;
        		return -1;
		    }
		    when 'corpCode' {
		        if (corpCode == compareToEmp.corpCode) return 0;
        		if (corpCode > compareToEmp.corpCode) return 1;
        		return -1;
		    }
		    when 'corpName' {
		        if (corpName == compareToEmp.corpName) return 0;
        		if (corpName > compareToEmp.corpName) return 1;
        		return -1;
		    }
		    when 'partnerCode desc' {
		        if (partnerCode == compareToEmp.partnerCode) return 0;
        		if (partnerCode > compareToEmp.partnerCode) return -1;
        		return 1; 
		    }	
		    when 'partnerName desc' {
		        if (partnerName == compareToEmp.partnerName) return 0;
        		if (partnerName > compareToEmp.partnerName) return -1;
        		return 1;
		    }
		    when 'corpCode desc' {
		        if (corpCode == compareToEmp.corpCode) return 0;
        		if (corpCode > compareToEmp.corpCode) return -1;
        		return 1;
		    }
		    when 'corpName desc' {
		        if (corpName == compareToEmp.corpName) return 0;
        		if (corpName > compareToEmp.corpName) return -1;
        		return 1;
		    }
            when 'partnerCode, corpCode' {
                if (partnerCode == compareToEmp.partnerCode && corpCode == compareToEmp.corpCode) return 0;
                if (partnerCode > compareToEmp.partnerCode) return 1;
                if (partnerCode == compareToEmp.partnerCode) {
                    if (corpCode == '') return -1;
                    if (corpCode > compareToEmp.corpCode) return 1;
                    return -1;
                }
                return -1;
            }
		    when else {
		        if (accId == compareToEmp.accId) return 0;
        		if (accId > compareToEmp.accId) return 1;
        		return -1;
		    }
		}
    }
}