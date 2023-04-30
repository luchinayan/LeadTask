trigger LeadConversionHistory on Lead (after update) {
        List<ConversionHistory__c> convHistList = new List<ConversionHistory__c>();

        for(Lead l : Trigger.new){
            if( l.IsConverted  && Trigger.oldMap.get(l.Id).IsConverted == false){
                ConversionHistory__c convH = new ConversionHistory__c();
                convH.Name = l.FirstName +' ' +l.LastName + ' converted';
                convH.LeadId__c = l.Id;
                convH.Timestamp__c = Datetime.now();
                convH.RecordOwnerId__c = l.OwnerId;
                convH.ConvertedOpportunityId__c = l.ConvertedOpportunityId;
                convH.ConvertedAccountId__c = l.ConvertedAccountId;
                if (l.ConvertedAccountId != null || l.ConvertedContactId != null ) {
                    convH.Matched__c = true;
                }
                convH.RecordConverterId__c = UserInfo.getUserId();
                convHistList.add(convH);
            }
        }

        insert convHistList;
}