/**
* @description CONSTANT変数定義クラス
*/
public with sharing class saConstantCmn 
{
	// Status for PushNotificationStatus picklists
    public static final String PUSH_NOTIFICATION_STATUS_NONE      = 'NONE';
    public static final String PUSH_NOTIFICATION_STATUS_SENDING   = 'SENDING';
    public static final String PUSH_NOTIFICATION_STATUS_RESENDING = 'RESENDING';
    public static final String PUSH_NOTIFICATION_STATUS_SENT      = 'SENT';

    // Picklist values for saMessageDetail__r.Type__c
    public static final String SA_MESSAGEDETAIL_TYPE_SHARED = 'SHARED';
    public static final String SA_MESSAGEDETAIL_TYPE_READ   = 'READ';
    public static final String SA_MESSAGEDETAIL_TYPE_DONE   = 'DONE';

    // Picklist values for saMessage__c.Type__c
    public static final String SA_MESSAGE_TYPE_MESSAGE = 'MESSAGE';
    public static final String SA_MESSAGE_TYPE_TASK    = 'TASK';

    // Picklist values for saInquiry__r.Type__c
    public static final String SA_INQUIRY_TYPE_DAILYREPORT = 'DAILY_REPORT';
    public static final String SA_INQUIRY_TYPE_HEARING     = 'SURVEY';
    public static final String SA_INQUIRY_TYPE_AU_HEARING     = 'AU_HEARING';

    // Picklist values for saReport__r.State__c
    public static final String SA_REPORT_STATE_DRAFT            = 'Draft';
    public static final String SA_REPORT_STATE_WAITING_APPROVAL = 'Pending';
    public static final String SA_REPORT_STATE_REJECTED         = 'Remand';
    public static final String SA_REPORT_STATE_PUBLISHED        = 'Publish';

    // Picklist values for saReportReply__r.Status__c
    public static final String SA_REPORT_REPLY_STATUS_WAITINGREPLY = 'WAITING_REPLY';
    public static final String SA_REPORT_REPLY_STATUS_REPLYSAVED   = 'REPLY_SAVED';
    public static final String SA_REPORT_REPLY_STATUS_REPLYSENT    = 'REPLY_SENT';

    // Source from which saReport is Access
    public static final String SA_REPORT_SOURCE_WEEKLY        	= 'Weekly';
    public static final String SA_REPORT_SOURCE_NEW      		= 'New';

	public static final String SA_REPORT_DETAIL_TYPE_LIKE        	= 'LIKE';
    public static final String SA_REPORT_DETAIL_TYPE_VERY_LIKE     		= 'VERY_LIKE';
    
    // Source to indicate the preview Mode
    public static final String SOURCE = 'src';
	public static final String SOURCE_PREVIEW = 'preview';
}