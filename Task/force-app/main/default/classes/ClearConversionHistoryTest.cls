@isTest
public class ClearConversionHistoryTest {
    @isTest
    public static void testClearConversionHistory() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(Name='Test Opportunity', StageName='Prospecting',CloseDate = Date.newInstance(2024, 4, 5));
        insert testOpportunity;
        User testUser = new User(
            FirstName='Test',
            LastName='User',
            Email='testuser@test.com',
            Username='testuser@iaaa.com',
            Alias='testu999',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=UserInfo.getProfileId()
        );
        insert testUser;
        Lead testLead = new Lead(
            FirstName='Test',
            LastName='Lead',
            Company='Test Company',
            Email='testlead@test.com',
            Phone='555-555-1212'
        );
        insert testLead;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setConvertedStatus('Closed - Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        ConversionHistory__c testHistory = new ConversionHistory__c(
            Name=testLead.FirstName + ' ' + testLead.LastName + ' converted',
            LeadId__c=testLead.Id,
            Timestamp__c=DateTime.now(),
            RecordOwnerId__c=testLead.OwnerId,
            ConvertedOpportunityId__c=testOpportunity.Id,
            ConvertedAccountId__c=testAccount.Id,
            Matched__c=true,
            RecordConverterId__c=testUser.Id
        );
        insert testHistory;

        Test.startTest();
        String cron = '0 0 0 ? * *'; 
        System.schedule('ClearConversionHistory', cron, new ClearConversionHistory());
        Test.stopTest();

        List<ConversionHistory__c> historyList = [SELECT Id FROM ConversionHistory__c];
        System.assertEquals(0, historyList.size(), 'Conversion history records were not deleted.');
    }
}
