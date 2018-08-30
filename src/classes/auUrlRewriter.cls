global class auUrlRewriter implements Site.UrlRewriter {

    /** 変換マップ用キー */
    static final List<String> URL_KEY_LIST = new List<String>{
        auConstantCmn.PAGE_ALIAS_SHOP_LOGIN.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_LOGOUT.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_FORGOTPWCOMP.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_FORGOTPWFORCE.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_FORGOTPW.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_PASSWORDSIGNUP.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_HOME.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_EVENTS.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_STPD.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_TIMELINE_STPD.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_CX.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_TIMELINE_CX.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_SCHEDULE.toLowerCase(),
        auConstantCmn.PAGE_ALIAS_SHOP_SCHEDULE_LIST.toLowerCase()
    };

    /** 変換マップ */
    static final Map<String, String> URL_CHANGE_MAP = new Map<String, String>{
        auConstantCmn.PAGE_ALIAS_SHOP_LOGIN.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_LOGIN,
        auConstantCmn.PAGE_ALIAS_SHOP_LOGOUT.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_LOGOUT,
        auConstantCmn.PAGE_ALIAS_SHOP_FORGOTPW.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_FORGOTPW,
        auConstantCmn.PAGE_ALIAS_SHOP_FORGOTPWCOMP.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_FORGOTPWCOMP,
        auConstantCmn.PAGE_ALIAS_SHOP_FORGOTPWFORCE.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_FORGOTPWFORCE,
        auConstantCmn.PAGE_ALIAS_SHOP_PASSWORDSIGNUP.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_PASSWORDSIGNUP,
        auConstantCmn.PAGE_ALIAS_SHOP_HOME.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_HOME,
        auConstantCmn.PAGE_ALIAS_SHOP_EVENTS.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_EVENTS,
        auConstantCmn.PAGE_ALIAS_SHOP_STPD.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_STPD,
        auConstantCmn.PAGE_ALIAS_SHOP_TIMELINE_STPD.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_TIMELINE_STPD,
        auConstantCmn.PAGE_ALIAS_SHOP_CX.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_CX,
        auConstantCmn.PAGE_ALIAS_SHOP_TIMELINE_CX.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_TIMELINE_CX,
        auConstantCmn.PAGE_ALIAS_SHOP_SCHEDULE.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_SCHEDULE,
        auConstantCmn.PAGE_ALIAS_SHOP_SCHEDULE_LIST.toLowerCase() => auConstantCmn.PAGE_VF_SHOP_SCHEDULE_LIST
    };

    global PageReference mapRequestUrl(PageReference myFriendlyUrl){
        String url = myFriendlyUrl.getUrl().toLowerCase();
        for (String keyUrl : URL_KEY_LIST) {
            keyUrl = keyUrl.toLowerCase();
            if (url.startsWith(keyUrl) && !url.startsWith(auConstantCmn.PAGE_ALIAS_SHOP_LOGIN.toLowerCase() + '?so=')) {
                String newUrl = '';
                if (url.length() != keyUrl.length()) {
                    newUrl = url.substring(keyUrl.length(), url.length());
                }
                return new PageReference(URL_CHANGE_MAP.get(keyUrl) + newUrl);
            }
        }
        // そのまま返す
        return myFriendlyUrl;
    }

    global List<PageReference> generateUrlFor(List<PageReference> mySalesforceUrls) {
        List<PageReference> myFriendlyUrls = new List<PageReference>();
        for (PageReference mySalesforceUrl : mySalesforceUrls) {
            myFriendlyUrls.add(mySalesforceUrl);
        }
        return myFriendlyUrls;
    }

}