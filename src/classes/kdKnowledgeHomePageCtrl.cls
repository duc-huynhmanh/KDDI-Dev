public with sharing class kdKnowledgeHomePageCtrl {
	public String errorMessage{get;set;}
	public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_KNOWLEDGE_DASHBOARD;}
	public List<ThemaBlock> kdKnwlListMap{get; private set;}
	public List<MenuItemData> seasonalThemas{get; private set;}
	public List<MenuItemData> menuItemList{get; private set;}
	public List<MenuItemData> typeItemList{get; private set;}
	public List<MenuItemData> channelItemList{get; private set;}
	public Integer totalItem{get; private set;}
	public Map<String, String> themaMap{get;set;}
	private Map<String, String> cateMap;
	private Map<String,Integer> mapKnowledgeCountItem;
	public String seasonalMessage{get;set;}
	public String textAlign{get;set;}

	public List<WebContent> topViewlist{get; private set;}
	public List<WebContent> recommendLastCreatedList{get; private set;}
	public List<WebContent> dentouiriLastCreatedList{get;private set;}

	private void getWebContentData(){
		topViewlist = new List<WebContent>();
		recommendLastCreatedList = new List<WebContent>(); 
		dentouiriLastCreatedList = new List<WebContent>();
		Integer index = 0;
		for (kdKnowledge__c k : [SELECT Title__c, NbView1Week__c, Thema__c FROM kdKnowledge__c ORDER BY NbView1Week__c DESC NULLS LAST, LastModifiedDate__c DESC LIMIT 3]){
			WebContent w = new WebContent();
			w.itemLabel = k.Title__c;
			w.itemThema = themaMap.get(k.Thema__c);
			w.index = index++;
			w.id = k.Id;
			topViewlist.add(w);
		}
		index = 0;
		for (kdKnowledge__c k : [SELECT Title__c, Thema__c FROM kdKnowledge__c WHERE RecommendFlag__c = True ORDER BY DisplayOrder__c DESC NULLS LAST, LastModifiedDate__c DESC LIMIT 3]){
			WebContent w = new WebContent();
			w.itemLabel = k.Title__c;
			w.itemThema = themaMap.get(k.Thema__c);
			w.index = index++;
			w.id = k.Id;
			recommendLastCreatedList.add(w);
		}
		index = 0;
		for (kdKnowledge__c k : [SELECT Title__c, Thema__c FROM kdKnowledge__c WHERE DentouiriFlag__c = True ORDER BY LastModifiedDate__c DESC LIMIT 3]){
			WebContent w = new WebContent();
			w.itemLabel = k.Title__c;
			w.itemThema = themaMap.get(k.Thema__c);
			w.index = index++;
			w.id = k.Id;
			dentouiriLastCreatedList.add(w);
		}
	}

	private void getSeasonalThema(){
		seasonalThemas = new List<MenuItemData>();
		auCommunityCustomSettings__c setting = auCommunityCustomSettings__c.getOrgDefaults();
		if(setting == null || String.isBlank(setting.SeasonalThema__c)){
			return;
		}
   		List<String> themas = setting.SeasonalThema__c.split(';');
		Integer index = 0;
		for(String t : themas){
			if(String.isBlank(t) || !themaMap.containsKey(t)) continue;
			MenuItemData item = new MenuItemData();
			item.apiName = t;
			if(t == 'Val29'){
        		item.iconName = 'Val29.png';
        	} else {
        		item.iconName = t + '.svg';
        	}
			item.displayLabel = themaMap.get(t);
			item.index = index++;
			for(MenuItemData menuItem : menuItemList){
				if(menuItem.apiName == t){
					item.count = menuItem.index;
					break;
				}
			}
			seasonalThemas.add(item);
		}
	}

	public List<MenuItemData> getListThema() {
        List<MenuItemData> menuItems = new List<MenuItemData>();
        Integer index = 0;
        for (Schema.PicklistEntry f : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
        	//push iPhone関連 on top
        	if(f.getValue() == 'Val20'){
        		MenuItemData item = new MenuItemData();
        		item.displayLabel = f.getLabel();
        		item.apiName = f.getValue();
        		item.iconName = f.getValue() + '.svg';
        		item.index = index++;
        		item.count = mapKnowledgeCountItem.get('Thema' + f.getValue());
        		if (item.count == null) {
        			item.count = 0;
        		}
            	menuItems.add(item);
            	break;
        	}
        }
        
        for (Schema.PicklistEntry f : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
        	if(f.getValue() == 'Val20'){
        		continue;
        	}

        	MenuItemData item = new MenuItemData();
        	item.displayLabel = f.getLabel();
        	item.apiName = f.getValue();
        	//set icon for Wowma!
        	if(f.getValue() == 'Val29'){
        		item.iconName = 'Val29.png';
        	} else {
        		item.iconName = f.getValue() + '.svg';
        	}
        	item.index = index++;
        	item.count = mapKnowledgeCountItem.get('Thema' + f.getValue());
        	if (item.count == null) {
        		item.count = 0;
        	}
            menuItems.add(item);
        }
        system.debug('menuItems: ' + menuItems);
        return menuItems;
    }

    public List<MenuItemData> getListType() {
        List<MenuItemData> menuItems = new List<MenuItemData>();
        Integer index = 0;
        for (Schema.PicklistEntry f : kdKnowledge__c.Type__c.getDescribe().getPicklistValues()) {
        	MenuItemData item = new MenuItemData();
        	item.displayLabel = f.getLabel();
        	item.apiName = f.getValue();
        	item.index = index++;
        	item.count = mapKnowledgeCountItem.get('Type' + f.getValue());
        	if (item.count == null) {
        		item.count = 0;
        	}
            menuItems.add(item);
        }
        system.debug('menuItems: ' + menuItems);
        return menuItems;
    }

    public List<MenuItemData> getListChannel() {
        List<MenuItemData> menuItems = new List<MenuItemData>();
        Integer index = 0;
        for (Schema.PicklistEntry f : kdKnowledge__c.SubjectDivision__c.getDescribe().getPicklistValues()) {
        	MenuItemData item = new MenuItemData();
        	item.displayLabel = f.getLabel();
        	item.apiName = f.getValue();
        	item.index = index++;
        	item.count = mapKnowledgeCountItem.get('Channel' + f.getValue());
        	if (item.count == null) {
        		item.count = 0;
        	}
            menuItems.add(item);
        }
        system.debug('menuItems: ' + menuItems);
        return menuItems;
    }

    public List<ThemaBlock> getDetailData(List<kdKnowledge__c> allKnowledges) {
        List<ThemaBlock> themaList = new List<ThemaBlock>();
        Set<String> fullThemaList = new Set<String>();
        for (kdKnowledge__c kdKnwl : allKnowledges){
        	//if collected 4 items for this thema
        	if(fullThemaList.contains(kdKnwl.Thema__c)) {
        		continue;
        	}
			Boolean isContains = false;
			//check thema is matching
			for (ThemaBlock t : themaList){
				if(t.strKey == kdKnwl.Thema__c) {
					isContains = true;
					t.listValue.add(kdKnwl);
					if(t.listValue.size() >= 4) {
						fullThemaList.add(t.strKey);							
					}
					break;
				}
			}
			//map does not contains key yet
			if(!isContains) {
				system.debug('thema: ' + kdKnwl.Thema__c);
				ThemaBlock themaItem = new ThemaBlock();
				themaItem.strKey = kdKnwl.Thema__c;
				themaItem.themaLabel = themaMap.get(kdKnwl.Thema__c);
				themaItem.category = cateMap.get(kdKnwl.MediumCategory__c);
				themaItem.listValue = new List<kdKnowledge__c>{kdKnwl};
				themaList.add(themaItem);
			}
		}

		system.debug('themaList before sort: ' + themaList);
		
		List<ThemaBlock> themaOrderedList = new List<ThemaBlock>();
		String previousCategory = '';
		for(MenuItemData menuItem : menuItemList) {
			for(ThemaBlock t : themaList){
				if(t.strKey == menuItem.apiName) {
					//check if the category is different -> display new category bar
					if(t.category != previousCategory) {
						previousCategory = t.category;
						t.isDisplayCategory = true;
					} else {
						t.isDisplayCategory = false;
					}
					themaOrderedList.add(t);
					break;
				}
			}
		}
		totalItem = themaOrderedList.size();
		system.debug('themaList after sort: ' + themaOrderedList);
        return themaOrderedList;
    }

	public kdKnowledgeHomePageCtrl() {
		themaMap = new Map<String, String>();
		mapKnowledgeCountItem = new Map<String,Integer>();
		Integer count;
		seasonalMessage = auCommunityCustomSettings__c.getOrgDefaults().SeasonalMessage__c;
		if(String.isEmpty(seasonalMessage)){
			seasonalMessage = '';
		} else {
			textAlign = seasonalMessage.contains('\n') ? 'left' : 'center';
		}
		List<kdKnowledge__c> allKnowledges = [SELECT Type__c, SubjectDivision__c, Thema__c, MediumCategory__c, NbCopy__c, NbLike__c, NbView__c, HasMovie__c, Title__c,
			PostTime__c, (SELECT Id FROM Attachments LIMIT 1)
			FROM kdKnowledge__c ORDER BY Thema__c, LastModifiedDate__c DESC];
		//count items 
		for(kdKnowledge__c k : allKnowledges){
			String typeStr = 'Type' + k.Type__c;
			String channelStr = 'Channel' + k.SubjectDivision__c;
			String themaStr = 'Thema' + k.Thema__c;
			if(mapKnowledgeCountItem.containsKey(typeStr)){
				count = mapKnowledgeCountItem.get(typeStr);
				count++;
				mapKnowledgeCountItem.put(typeStr, count);
			} else {
				mapKnowledgeCountItem.put(typeStr, 1);
			}

			if(mapKnowledgeCountItem.containsKey(channelStr)){
				count = mapKnowledgeCountItem.get(channelStr);
				count++;
				mapKnowledgeCountItem.put(channelStr, count);
			} else {
				mapKnowledgeCountItem.put(channelStr, 1);
			}

			if(mapKnowledgeCountItem.containsKey(themaStr)){
				count = mapKnowledgeCountItem.get(themaStr);
				count++;
				mapKnowledgeCountItem.put(themaStr, count);
			} else {
				mapKnowledgeCountItem.put(themaStr, 1);
			}
		}
        for (Schema.PicklistEntry f : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
            themaMap.put(f.getValue(), f.getLabel());
        }  
        cateMap = new Map<String, String>();
        for (Schema.PicklistEntry f : kdKnowledge__c.MediumCategory__c.getDescribe().getPicklistValues()) {
            cateMap.put(f.getValue(), f.getLabel());
        } 
        getWebContentData();
		menuItemList = getListThema();
		typeItemList = getListType();
		channelItemList = getListChannel();
		kdKnwlListMap = getDetailData(allKnowledges);
		getSeasonalThema();
	}

	public class MenuItemData {
        // List property
        public String displayLabel		{get;set;}
        public String apiName			{get;set;}
        public String iconName			{get;set;}
        public Integer index			{get;set;}
        public Integer count			{get;set;}
    }

    public class ThemaBlock {
    	public string category 					{get;set;}
    	public Boolean isDisplayCategory		{get;set;}
    	public string strKey 					{get;set;}
    	public string themaLabel 				{get;set;}
    	public List<kdKnowledge__c> listValue 	{get;set;}
    }

    public class WebContent{
    	public string itemLabel  {get;set;}
    	public string itemThema  {get;set;}
    	public String id 		 {get;set;}
    	public Integer index 	 {get;set;}
    }
}