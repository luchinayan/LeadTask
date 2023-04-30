global class ClearConversionHistory implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // ClearConversionHistory cleaner = new ClearConversionHistory();
        // String cron = '0 51 14 * * ?'; 
        // System.schedule('History Cleanup', cron, cleaner);
        
        Set<Id> converterIds = new Set<Id>();
        for(ConversionHistory__c history : [SELECT RecordConverterId__c FROM ConversionHistory__c ]) {
            converterIds.add(history.RecordConverterId__c);
        }
        Map<Id, List<ConversionHistory__c>> converterIdToHistoryMap = new Map<Id, List<ConversionHistory__c>>();

        for (ConversionHistory__c history : [
            SELECT ConvertedAccountId__c, ConvertedOpportunityId__c, Timestamp__c, RecordConverterId__c 
            FROM ConversionHistory__c 
            WHERE RecordConverterId__c IN :converterIds 
        ]) {
            converterIdToHistoryMap.put(history.RecordConverterId__c, new List<ConversionHistory__c>{history});
        }
     

        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Name, LastModifiedDate 
        FROM Account WHERE CreatedDate = THIS_WEEK]);
      
        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([SELECT Id, Name, StageName
         FROM Opportunity WHERE CreatedDate = THIS_WEEK]);

        for (User converter : [SELECT Id, Name, Email FROM User WHERE Id IN :converterIds]) {
          
            String emailBody = 'Hello ' + converter.Name + ',<br/><br/>';
            emailBody += 'Here is the current status of Accounts and Opportunities that you converted Leads to:<br/><br/>';
           
                List<ConversionHistory__c> converterHistoryList = converterIdToHistoryMap.get(converter.Id);
                
                for(ConversionHistory__c history :converterHistoryList){
                    
                Account account = accountsMap.get(history.ConvertedAccountId__c);
              
                Opportunity opportunity = opportunitiesMap.get(history.ConvertedOpportunityId__c);
                    if (account != null) {
                        emailBody += 'Account Name: ' + account.Name + '<br/>';
                        if (account.LastModifiedDate > history.Timestamp__c) {
                            emailBody += 'Account was modified after conversion<br/>';
                        }
                        emailBody += '<br/>';
                    }
                    if (opportunity != null) {
                        emailBody += 'Opportunity Name: ' + opportunity.Name + '<br/>';
                        emailBody += 'Opportunity Stage: ' + opportunity.StageName + '<br/><br/>';
                }
              
                
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{converter.Email});
            mail.setSubject('Weekly Conversion History Update');
            mail.setHtmlBody(emailBody);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
          
        List<ConversionHistory__c> historyToDelete = [SELECT Id FROM ConversionHistory__c];
        delete historyToDelete;
        
    }
}