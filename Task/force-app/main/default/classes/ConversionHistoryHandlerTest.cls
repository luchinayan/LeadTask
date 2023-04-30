@IsTest
private class ConversionHistoryHandlerTest {

    static testMethod void testLeadConversionHistoryTrigger() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@test.com',
            Phone = '555-555-1212',
            OwnerId=UserInfo.getUserId()
        );
        insert testLead;
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setConvertedStatus('Closed - Converted');
        lc.setDoNotCreateOpportunity(true);
        lc.setAccountId(testAccount.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        List<ConversionHistory__c> convHistList = [
            SELECT LeadId__c, RecordOwnerId__c, ConvertedOpportunityId__c,
                ConvertedAccountId__c, RecordConverterId__c, Matched__c
            FROM ConversionHistory__c
            WHERE LeadId__c = :testLead.Id
        ];
        System.assertEquals(1, convHistList.size(), 'The size of the ConversionHistory list is not as expected.');
        ConversionHistory__c convHist = convHistList[0];
        System.assertEquals(testLead.Id, convHist.LeadId__c, 'The Lead ID of the ConversionHistory record is not as expected.');
        System.assertEquals(testLead.OwnerId, convHist.RecordOwnerId__c, 'The Owner ID of the ConversionHistory record is not as expected.');
        System.assertEquals(null, convHist.ConvertedOpportunityId__c, 'The Converted Opportunity ID of the ConversionHistory record is not as expected.');
        System.assertEquals(testAccount.Id, convHist.ConvertedAccountId__c, 'The Converted Account ID of the ConversionHistory record is not as expected.');
        System.assertEquals(UserInfo.getUserId(), convHist.RecordConverterId__c, 'The Record Converter ID of the ConversionHistory record is not as expected.');
        System.assertEquals(true, convHist.Matched__c, 'The Matched field of the ConversionHistory record is not as expected.');
    }
}
