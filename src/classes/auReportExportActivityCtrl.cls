public with sharing class auReportExportActivityCtrl {

    public auReportExportActivityCtrl() {
    
    }
    
    public PageReference redirect(){

        List<report> lsRep = [SELECT id FROM report WHERE DeveloperName LIKE 'EventDailyReportExport%'];
        if (lsRep != NULL && lsRep.size() > 0) {
            return new PageReference('/' + lsRep[0].id);
        }
        return null;

    }
    
}