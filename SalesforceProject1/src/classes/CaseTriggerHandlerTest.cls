@isTest
public class CaseTriggerHandlerTest {

    @testSetup
    static void setup(){
        Account acc = new Account(BillingCountry='United States', Name='test');
		Contact con = new Contact(AccountId=acc.Id, Email='test@email.com', LastName='test');
        Case c = new Case(Origin='Email', Subject='test@email.com');
        insert acc;
        insert con;
        insert c;
        Opportunity opp = new Opportunity(Name = 'test', StageName = 'Specification', CloseDate = System.today());
        insert opp;
    }
    
    @isTest static void test_CaseTriggerBeforeInsert(){
        test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case c = [SELECT Id, AccountId, ContactId FROM Case LIMIT 1];       
        test.stopTest();
        System.assertEquals(con.Id, c.ContactId);
    }
    
    @isTest static void test_CaseTriggerAfterUpdate(){
        test.startTest();
        Case c = [SELECT Id, AccountId, ContactId, ArmaGel_Opportunity__c, Project__c, PET_OEM_Opportunity__c, PET_OEM_Project__c, PET_Opportunity__c, Sub_Project__c FROM Case LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        c.Project__c = opp.Id;
        update c;
        test.stopTest();
        System.assertEquals(null, c.ArmaGel_Opportunity__c);
        System.assertEquals(opp.Id, c.Project__c);
        System.assertEquals(null, c.PET_OEM_Opportunity__c);
        System.assertEquals(null, c.PET_OEM_Project__c);
        System.assertEquals(null, c.PET_Opportunity__c);
        System.assertEquals(null, c.Sub_Project__c);        
    }
}