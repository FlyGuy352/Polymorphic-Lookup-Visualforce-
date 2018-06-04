public class CaseTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        updateCaseContactAndAccount();
    }

    public override void beforeUpdate() {
        validateRelatedProject();
    }

    private void updateCaseContactAndAccount() {
        Map<Case,String> caseToEmailMap = new Map<Case,String>();
        Map<String,Contact> caseEmailToContactMap = new Map<String,Contact>();        
		/*This trigger is intended to apply to Cases created via Email-to-Case.
		Before insert trigger on Case object has been chosen over after insert trigger on EmailMessage object
		in the interest of saving DML transactions.*/
        for(Case c : (List<Case>)trigger.new) {
            if(c.Origin == 'Email') {
                String subject = c.Subject;
                String email;
                String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';
                Pattern MyPattern = Pattern.compile(emailRegex);
                try {
                    Matcher MyMatcher = MyPattern.matcher(subject);
                    if(MyMatcher.find()) {
                        email = MyMatcher.group(0);
                        c.Customer_Email__c = email;                    
                        caseToEmailMap.put(c, email);                         
                    }
                } catch(Exception e) {
                    // Logic if email not found in subject                    
                }
            }
        }

        List<Contact> contactsForCase = [SELECT Id, Email FROM Contact WHERE Email = :caseToEmailMap.values()];
        for(Contact con : contactsForCase) {
            caseEmailToContactMap.put(con.Email, con);
        }

        for(Case c : caseToEmailMap.keySet()) {
            try {
                Contact con = caseEmailToContactMap.get(caseToEmailMap.get(c));
                c.contactId = con.Id;
                try {
                    c.AccountId = con.AccountId;           
                } catch(Exception e) {
                    //Logic if there is Contact Id but no Account Id
                }       
            } catch(Exception e) {
                //Logic if there is no Contact Id
            }            
        }
    }

    private void validateRelatedProject() {

        Map<String, String> oldRelatedProjects = new Map<String, String>();
        Map<String, String> newRelatedProjects = new Map<String, String>();
        for(Case newCase : (List<Case>)trigger.new) {
            Case oldCase = (Case)trigger.oldMap.get(newCase.ID);
            
            oldRelatedProjects.put('ArmaGel Opportunities', oldCase.ArmaGel_Opportunity__c);
            oldRelatedProjects.put('Projects', oldCase.Project__c);            
            oldRelatedProjects.put('PET OEM Opportunities', oldCase.PET_OEM_Opportunity__c);
            oldRelatedProjects.put('PET OEM Projects', oldCase.PET_OEM_Project__c);
            oldRelatedProjects.put('PET Opportunities', oldCase.PET_Opportunity__c);            
            oldRelatedProjects.put('Sub Projects', oldCase.Sub_Project__c);
            
            newRelatedProjects.put('ArmaGel Opportunities', newCase.ArmaGel_Opportunity__c);
            newRelatedProjects.put('Projects', newCase.Project__c);            
            newRelatedProjects.put('PET OEM Opportunities', newCase.PET_OEM_Opportunity__c);
            newRelatedProjects.put('PET OEM Projects', newCase.PET_OEM_Project__c);
            newRelatedProjects.put('PET Opportunities', newCase.PET_Opportunity__c);            
            newRelatedProjects.put('Sub Projects', newCase.Sub_Project__c);
            
            for(String typeOfProject : newRelatedProjects.keySet()) {
                if(newRelatedProjects.get(typeOfProject) != null && oldRelatedProjects.get(typeOfProject) == null && oldRelatedProjects.values() != null) {
                    if(typeOfProject != 'ArmaGel Opportunities') {
                    	newCase.ArmaGel_Opportunity__c = null;                        
                    }
                    if(typeOfProject != 'Projects') {
                    	newCase.Project__c = null;                        
                    }
                    if(typeOfProject != 'PET OEM Opportunities') {
                        newCase.PET_OEM_Opportunity__c = null;
                    }
                    if(typeOfProject != 'PET OEM Projects') {
                        newCase.PET_OEM_Project__c = null;
                    }
                    if(typeOfProject != 'PET Opportunities') {
                    	newCase.PET_Opportunity__c = null;
                    }
                    if(typeOfProject != 'Sub Projects') {
                    	newCase.Sub_Project__c = null;
                    }
                }
            }
        }
    }
}