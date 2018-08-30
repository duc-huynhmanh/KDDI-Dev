@isTest
public class ContentDocumentLinkTriggerTest {
    
    @isTest static void ContentDocumentLinkTriggerTest() {
        
        // Create a auチャンネル
        auHonbuDirect__c hd = new auHonbuDirect__c();
        for (Schema.PicklistEntry val : auHonbuDirect__c.Category__c.getDescribe().getPicklistValues()){
            hd.Category__c = val.getValue();
            break;
        }
        hd.ImplementationEndDate__c = Date.today();
        hd.ImplementationStartDate__c = Date.today();
        hd.TransmissionDate__c = Date.today();
        hd.Title__c = 'test';
        Insert hd;

        // Create a ContentVersion
        ContentVersion ContentDoc = new ContentVersion();
        ContentDoc.Title = 'My Doc';
        ContentDoc.ContentUrl= 'test.com';
        Insert ContentDoc;
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :ContentDoc.Id];
        
        // Create a ContentDocumentLink
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = testcontent.contentdocumentid;
        ContentDL.LinkedEntityId = hd.Id;
        Insert ContentDL;
        
    }
}