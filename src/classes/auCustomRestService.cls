@RestResource(urlMapping='/GpsTracking/*')
global without sharing class auCustomRestService {
    
     @HttpPost
	global static void doPost(String User, DateTime LocationDateTime, Double latitude, Double longitude) {
		
		//APEX code goes here to query and create records
		kdGpsTracking__c newGPSData = new kdGpsTracking__c();
		newGPSData.Datetime__c=LocationDateTime;
		newGPSData.GeoLocation__latitude__s=latitude;
		newGPSData.GeoLocation__longitude__s=longitude;
		newGPSData.User__c=User;
		insert(newGPSData);
		
    }
    
}