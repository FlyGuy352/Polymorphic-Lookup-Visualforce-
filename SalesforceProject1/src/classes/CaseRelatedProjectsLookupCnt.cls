public with sharing class CaseRelatedProjectsLookupCnt {
@TestVisible private final Case recordCase;
@TestVisible private final Id recordId;
@TestVisible private final ApexPages.StandardController standardController;
    public String Projects {get; set;}
    public String Project {get; set;}
        
    public CaseRelatedProjectsLookupCnt(ApexPages.StandardController stdController) {
        standardController = stdController;
		recordId = stdController.getId();
        recordCase = [SELECT Id, ArmaGel_Opportunity__c, Project__c, PET_OEM_Opportunity__c, PET_OEM_Project__c, PET_Opportunity__c, Sub_Project__c FROM Case WHERE Id = :recordId]; 
        setupProjects();
    }

    public List<SelectOption> getCaseRelatedProjects() {
        // do a field describe of the picklist field
        Schema.DescribeFieldResult relatedProjects = Case.RelatedProjects__c.getDescribe();
        // get the picklist values from this describe result
        List<Schema.PicklistEntry> entries = relatedProjects.getPicklistValues();
        // list of options to be returned to the VF page
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        for (Schema.PicklistEntry pEntry : entries) {
            if (pEntry.isActive()) {
                optionsToReturn.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }
        return optionsToReturn;
    }

	private void setupProjects() {
        if(recordCase.ArmaGel_Opportunity__c != null) {
            Projects = 'ArmaGel Opportunities';
        } else if(recordCase.Project__c != null) {
            Projects = 'Opportunities';
        } else if(recordCase.PET_OEM_Opportunity__c != null) {
            Projects = 'PET OEM Opportunities';
        } else if(recordCase.PET_OEM_Project__c != null) {
            Projects = 'PET OEM Projects';
        } else if(recordCase.PET_Opportunity__c != null) {
            Projects = 'PET Opportunities';
        } else if(recordCase.Sub_Project__c != null) {
			Projects = 'Sub Projects';
        }
    }
    
    public PageReference classicSave() {   
        standardController.save();
        PageReference pageRef = new PageReference('/apex/CaseRelatedProjectLookUp?id=' + recordId); 
        pageRef.setRedirect(true); 
        return pageRef;
    }
    /*public List<SelectOption> getCaseRelatedProject() {
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        for(String record : retrieveProjectRecords('Opportunity')) {
            optionsToReturn.add(new SelectOption(record, record));
        }
        return optionsToReturn;
    }

    private static List<String> retrieveProjectRecords(String selectedProject) {
        List<Sobject> recordsToRetrieve = new List<Sobject>();
        String query = 'SELECT Id, Name FROM Opportunity';
        recordsToRetrieve = Database.query(query);
        System.debug(query);

        //Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        //Schema.SobjectType oType = gd.get(selectedProject);	
        //sObject sObj = Schema.getGlobalDescribe().get(selectedProject).newSObject();

        Map<Id, String> recordToNameMap = new Map<Id, String>();
        for(Sobject s : recordsToRetrieve) {
            recordToNameMap.put(s.Id, (String)s.get('Name'));
            System.debug(recordToNameMap);
        }
        return recordToNameMap.values();
    }*/
}