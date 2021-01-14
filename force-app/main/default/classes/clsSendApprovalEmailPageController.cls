public class clsSendApprovalEmailPageController {
//agregar una Instancia para el Standard Controller 
    private ApexPages.StandardController controller {get; set;}
    //Agrega la instancia para las variables que son pasadas por id en la url
    Opportunity opp {get; set;}
    //Se usa para asignar/mantener el nuevo id creado en Opp  
    public ID newRecordId {get; set;}
    
    public clsSendApprovalEmailPageController(ApexPages.StandardController controller) 
	{
        this.controller=controller;
        //Cargar el Registro Actual
        opp=(Opportunity)controller.getRecord();        
	}
    
    
    //Metodo llamado desde la VF action
    public PageReference SendEmail(){
         
    Savepoint sp=Database.setSavepoint();
    Opportunity newOpp;
        
        try{
              
        
        opp=[Select id,Name,RecordTypeID,Contact__c,AccountId,StageName,CloseDate,CAG_New_Order__c from Opportunity where Id=:opp.Id];
       
           if(opp.Contact__c==null){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact is required' );
       			ApexPages.addMessage(msg);
            }
            
        Contact contact=[Select id,email, name  from Contact where id=:opp.Contact__c];
        Account account=[Select id, name  from account where id=:opp.AccountId];
         
            if(contact.Email==null){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact email is required' );
       			ApexPages.addMessage(msg);
            }
            
        
        String subject='';   
        
        if(opp.CAG_New_Order__c!=null){
        	 subject=opp.CAG_New_Order__c;
            }
        //Task related to Account
        Task task=new Task();
        task.ActivityDate=date.Today();
        task.Status='Completed';
        task.Subject  =account.name+' - '+'URGENT - APPROVAL REQUIRED FOR ORDER #'+subject;
        task.WhatId=opp.id;
        
        insert task;
            
        //Email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
   		message.setTargetObjectId(contact.id); 
   		message.setSenderDisplayName(contact.name); 
        
   		//message.setReplyTo('no-reply@company.com');
   		message.setUseSignature(false); 
   		message.setBccSender(false); 
   		message.setSaveAsActivity(false); 
        
  		EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName= 'Approval_Email'];
  		if (emailTemplate !=null){
        	message.setTemplateID(emailTemplate.Id);
               //message.setPlainTextBody(emailTemplate.Body);
        }
        if(opp.CAG_New_Order__c !=null){
  			message.setWhatId(opp.Id); //This is important for the merge fields in template to work
  		}
         if(contact !=null){    
        	message.toAddresses = new String[] { contact.email};
          }
  		
        //Atachment from ContentVersion    
        List<id> ContentDocumentids = new List<id>();

		for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:opp.Id]){
			   ContentDocumentids.add(CDLink.ContentDocumentid);  
			}
            
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            
		for ( ContentVersion cversion : [SELECT title,PathOnClient, FileType,VersionData,Proof__c FROM ContentVersion WHERE  Proof__c=TRUE AND ContentDocumentId IN :ContentDocumentids  ]){
			  
            if(cversion !=null){
              blob WOCFbody = cversion.VersionData;
			  //system.debug('body : '+WOCFbody+'-----------'+cversion.title);
			  Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			  efa.setFileName(cversion.title+'.'+cversion.FileType);
			  efa.setBody(WOCFbody);
              efa.setInline(false);
            
			  fileAttachments.add(efa); 
            }
			 }
        
        
        	message.setFileAttachments(fileAttachments);
            
            
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
  		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            
 		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Approval Email sent successfully' );
        ApexPages.addMessage(msg);
        
        
       }catch(Exception e){
            System.debug('Error'+e);
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    }
}