public with sharing class auSendEmailUtil {

    /** メッセージリスト */
    private List<Messaging.SingleEmailMessage> messages;

    /**
     * コンストラクタ
     */
    public auSendEmailUtil () {
        messages = new List<Messaging.SingleEmailMessage>();
    }

    /**
     * メッセージ作成
     * @param replyTo 返信先アドレス
     * @param senderDisplayName 差出人名
     * @param toAddresses To アドレス
     * @param ccAddresses Cc アドレス
     * @param subject 件名
     * @param planText 本文
     */
    public void createSendMessage(
              String orgWideEmailAddressId
            , String targetObjectId
            , String subject
            , String planText) {

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setOrgWideEmailAddressId(orgWideEmailAddressId);
        message.setTargetObjectId(targetObjectId);
        message.setSubject(subject);
        message.setPlainTextBody(planText);
        message.setSaveAsActivity(false);


        addMessage(message);
    }

//20171115 masao.endo add start
    /**
     * メッセージ作成(CC付き)
     * @param orgWideEmailAddressId 返信先アドレス
     * @param targetObjectId To アドレス（内部ユーザ）
     * @param toAddresses To アドレス
     * @param ccAddresses Cc アドレス
     * @param bccAddresses Bcc アドレス
     * @param subject 件名
     * @param planText 本文
     * @param onlyToFlg 宛先が一件のみのかのフラグ
     */
    public void createTOCCBCCSendMessage(
            String orgWideEmailAddressId
            , String targetObjectId
            ,String[] toAddresses
            , String[] ccAddresses
            , String[] bccAddresses
            , String subject
            , String planText
            , Boolean onlyToFlg) {

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(onlyToFlg) {
            message.setTargetObjectId(targetObjectId);
        } else {
            message.setToAddresses(toAddresses);
        }
        message.setSubject(subject);
        message.setPlainTextBody(planText);
        message.setSaveAsActivity(false);
        if (ccAddresses.size() > 0 && ccAddresses != null){
            message.setCCAddresses(ccAddresses);
        }
        if (bccAddresses.size() > 0 && bccAddresses != null){
            message.setBCCAddresses(bccAddresses);
        }
        addMessage(message);
    }
//20171115 masao.endo add end

    /**
     * メッセージ追加
     * @param message メッセージ
     */
    private void addMessage(Messaging.SingleEmailMessage message) {
        if(messages == null) {
            messages = new List<Messaging.SingleEmailMessage>();
        }
        messages.add(message);
    }


    /**
     * メール送信
     */
    public List<SendResponse>  sendMail() {
        List<SendResponse> retResponse = new List<SendResponse>();
        if(messages != null && messages.size() > 0) {
            List<Messaging.SendEmailResult> results =Messaging.sendEmail(messages);
            for(Messaging.SendEmailResult result :results){
                SendResponse res;
                if (result.isSuccess()) {
                    // メール送信に成功した時の処理
                    System.debug('send mail Succeeded');
                    res = new  SendResponse(200, '');
                } else {
                    System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                    String errorMessage = results.get(0).getErrors()[0].getMessage();
                    System.debug('senmail Failed'+errorMessage);
                    res = new  SendResponse(400, res.message);
                }
                retResponse.add(res );
            }
        }
        return retResponse;
    }

  public class SendResponse {
    public Integer code { get; private set; }
    public Boolean success { get; private set; }
    public String message { get; private set; }

    public SendResponse(Integer code, String body) {
      this.code = code;
      this.success = code == 200;
      this.message = body;
    }
  }

}