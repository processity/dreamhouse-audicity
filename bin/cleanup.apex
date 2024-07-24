List<Contact> contacts = [SELECT Id, FirstName, LastName from Contact];
Map<Id, Property__c> propMap = new Map<Id, Property__c>([SELECT Id, Name from Property__c]);
List<Broker__c> brokers = [SELECT Id, Name from Broker__c];


List<Campaign> campaigns = [SELECT Id, Name from Campaign WHERE Property__c IN :propMap.keyset()];

delete contacts;
delete campaigns;
delete propMap.values();
delete brokers;

System.debug('Contacts Remaining: ' + [SELECT count(Id) FROM Contact]);
System.debug('Campaigns Remaining: ' + [SELECT count(Id) FROM Campaign]);
System.debug('Brokers Remaining: ' + [SELECT count(Id) FROM Broker__c]);
System.debug('Properties Remaining: ' + [SELECT count(Id) FROM Property__c]);