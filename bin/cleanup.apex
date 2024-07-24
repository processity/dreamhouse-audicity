/**
 * This script exists to reset the org data in the dreamhouse-audicity sample app. 
 * 
 * It is designed to wipe all data from the Property__c and Broker__c objects.
 * 
 * The Campaign and Contact objects will only have the records removed that
 * were either part of the original import from the dreamhouse-audicity
 * project, or (in the case of Campaign) where a campaign is related
 * to a property record. Changes to contact records may mean that this 
 * script may fail to fully remove all contact records. 
 */

// collect data from the four objects used in Dreamhouse. 

List<String> contactEmails = new List<String>('bholmes@goodmail.com', 'leslie@pentagon.com', 'julywalker@brain.com', 'annaj@mymail.com', 'jconnor@goodmail.com');

List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact WHERE Email IN: contactEmails];
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
