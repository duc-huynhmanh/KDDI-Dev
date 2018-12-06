@isTest
private class auCustomRestServiceTest {

	static String locationId; 
	static DateTime locationDateTime;
	static Double locationlatitude;
	static Double locationlongitude;

	static void init(){
		
		User adminUser = auTestDataUtil.createAdminUser('admin');
		locationId = adminUser.Id;
		locationDateTime = dateTime.now();
	    locationlatitude = 0;
	    locationlongitude = 0;
	}
    
    @isTest
    static void callCustomPostMethod_Test() {
    	
    	system.debug('Run callCustomPostMethod_Test');

		Test.startTest();
		
		init();
		
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
	    req.requestURI = '/services/apexrest/GpsTracking/';
	         
	    req.httpMethod = 'POST';
	    req.addHeader('Content-Type', 'application/json'); 
	        
	    RestContext.request = req;
	    RestContext.response= res;
	        
	    //Test.setMock(HttpCalloutMock.class, new auCustomRestServiceMock());
	    callCustomPostMethod_Future(locationId,locationDateTime,locationlatitude,locationlongitude);      
   		Test.stopTest();   
   		
    }
    
    @future
	private static void callCustomPostMethod_Future(String User, DateTime LocationDateTime, Double latitude, Double longitude){
		
		auCustomRestService.doPost(User,LocationDateTime,latitude,longitude);    
		
	}

}