@SuppressWarnings('PMD.ExcessiveParameterList,PMD.ApexCRUDViolation')
public with sharing class PropertyTriggerHandler {
    /*
    This contrived example exists to illustrate two different transaction profiles of Audicity. First, 
    on insert, a standard DML transaction that inserts a new Campaign when there is a new Property under
    certain conditions. 

    The other, on update, illustrates a transaction that uses Queuables to show a trace across several
    execution contexts. 
    */

    public static void handleTrigger(
        List<Property__c> workingRecords,
        Map<Id, Property__c> workingMap,
        Map<Id, Property__c> oldMap,
        System.TriggerOperation triggerEvent
    ) {
        switch on triggerEvent {
            when AFTER_INSERT {
                //setup campaign for each property
                createCampaignForNewProperty(workingRecords);
            }
            when AFTER_UPDATE {
                //set campaign status when property goes on market
                updateCampaignOnPropertyUpdate(workingMap, oldMap);
            }
            //do nothing for AFTER_UNDELETE, AFTER_DELETE, BEFORE_DELETE, BEFORE_UPDATE, BEFORE_INSERT
        }
    }

    public static void createCampaignForNewProperty(
        List<Property__c> properties
    ) {
        List<Campaign> campaigns = new List<Campaign>();

        for (Property__c prop : properties) {
            if (
                prop.Status__c == 'Contracted' ||
                prop.Status__c == 'Pre Market'
            ) {
                Campaign newCampaign = new Campaign(
                    Name = prop.Name +
                        ' Main Campaign ' +
                        ' ' +
                        Date.today().year() +
                        '-' +
                        Date.today().month(),
                    ExpectedRevenue = prop.Price__c,
                    Status = 'Planned',
                    Type = 'Advertisement',
                    Property__c = prop.Id,
                    StartDate = Date.today().addDays(14)
                );
                campaigns.add(newCampaign);
            }
        }
        Database.insert(campaigns);
    }

    public static void updateCampaignOnPropertyUpdate(
        Map<Id, Property__c> workingMap,
        Map<Id, Property__c> oldMap
    ) {
        List<Property__c> propsUpdateStatus = new List<Property__c>();
        List<Property__c> propsUpdatePrice = new List<Property__c>();

        for (Property__c prop : workingMap.values()) {
            if (prop.Price__c != oldMap.get(prop.Id).Price__c) {
                propsUpdatePrice.add(prop);
            }

            if (prop.Status__c != oldMap.get(prop.Id).Status__c) {
                propsUpdateStatus.add(prop);
            }
        }

        if (propsUpdateStatus?.size() > 0) {
            PropertyCampaignStatusUpdateQueueable asyncStatus = new PropertyCampaignStatusUpdateQueueable(
                propsUpdateStatus
            );
            Id jobId = System.enqueueJob(asyncStatus);
            // ***** Add your Audicity instrumentation code on the line immediately following this comment *****

            // ***** Add your Audicity instrumentation code on the line immediately before this comment *****
        }

        if (propsUpdatePrice?.size() > 0) {
            PropertyCampaignPriceUpdateQueueable asyncPrice = new PropertyCampaignPriceUpdateQueueable(
                propsUpdatePrice
            );
            Id jobId = System.enqueueJob(asyncPrice);
            // ***** Add your Audicity instrumentation code on the line immediately following this comment *****

            // ***** Add your Audicity instrumentation code on the line immediately before this comment *****
        }
    }
}
