/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPropertyTrigger {
    @isTest
    private static void insertNoCampaignForPropertiesWithWrongStatus() {
        // Properties without the right status values should have no campaigns associated with them
        Integer numTestProperties = 10;

        Test.startTest();
        TestDataFactory.createProperties(numTestProperties, 'Available');
        Test.stopTest();

        Integer numProperties = [SELECT COUNT() FROM Property__c];
        Integer numCampaigns = [SELECT COUNT() FROM Campaign];

        System.Assert.areEqual(
            numTestProperties,
            numProperties,
            'Expected 10 properties. '
        );
        System.Assert.areEqual(0, numCampaigns, 'Expected 0 campaigns.');
    }

    @isTest
    private static void insertOneCampaignPerPropertyForContractedStatus() {
        // Properties with the status of 'Contracted' should have a related Campaign when inserted
        Integer numTestProperties = 5;

        Test.startTest();
        TestDataFactory.createProperties(numTestProperties, 'Contracted');
        Test.stopTest();

        Integer numProperties = [SELECT COUNT() FROM Property__c];
        Integer numCampaigns = [SELECT COUNT() FROM Campaign];

        System.Assert.areEqual(
            numTestProperties,
            numProperties,
            'Wrong number of properties created. '
        );
        System.Assert.areEqual(
            numProperties,
            numCampaigns,
            'Every property has a campaign when status is Contracted.'
        );
    }

    @isTest
    private static void insertOneCampaignPerPropertyForPreMarketStatus() {
        // Properties with the status of 'Pre Market' should have a related Campaign when inserted
        Integer numTestProperties = 5;

        Test.startTest();
        TestDataFactory.createProperties(numTestProperties, 'Pre Market');
        Test.stopTest();

        Integer numProperties = [SELECT COUNT() FROM Property__c];
        Integer numCampaigns = [SELECT COUNT() FROM Campaign];

        System.Assert.areEqual(
            numTestProperties,
            numProperties,
            'Wrong number of properties created. '
        );
        System.Assert.areEqual(
            numProperties,
            numCampaigns,
            'Every property has a campaign when status is Pre Market.'
        );
    }

    @isTest
    private static void insertOneCampaignPerPropertyForPreMarketStatus_Bulk() {
        // Bulk insert trigger
        Integer numTestProperties = 201;

        Test.startTest();
        TestDataFactory.createProperties(numTestProperties, 'Pre Market');
        Test.stopTest();

        Integer numProperties = [SELECT COUNT() FROM Property__c];
        Integer numCampaigns = [SELECT COUNT() FROM Campaign];

        System.Assert.areEqual(
            numTestProperties,
            numProperties,
            'Wrong number of properties created. '
        );
        System.Assert.areEqual(
            numProperties,
            numCampaigns,
            'Every property has a campaign when status is Pre Market.'
        );
    }

    @isTest
    private static void updatePropertyStatus() {
        // When Property Status__c is updated, Campaign Status and IsActive get updated according to mapping
        final Integer numTestProperties = 1;
        final String testPropertyStatusValue = 'Contracted';
        final String newStatusToTest = 'Available';

        List<Property__c> testProperties = TestDataFactory.getPropertiesForTest(
            numTestProperties,
            testPropertyStatusValue
        );

        System.Assert.areEqual(1, testProperties.size(), 'Wrong test set size');
        System.Assert.areEqual(
            testProperties.size(),
            testProperties.get(0).Campaigns__r.size(),
            'Number of campaigns does not match number of properties'
        );

        Property__c testProperty = testProperties.get(0);
        String startStatus = testProperty.Status__c;

        System.Assert.areEqual(
            PropertyCampaignStatusUpdateQueueable.STATUS_MAP.get(startStatus),
            testProperty.Campaigns__r.get(0).Status,
            'Start state Campaign status not correctly set according to mapped property status'
        );
        System.Assert.areEqual(
            PropertyCampaignStatusUpdateQueueable.ACTIVE_MAP.get(startStatus),
            testProperty.Campaigns__r.get(0).IsActive,
            'Start state Campaign IsActive flag not correctly set according to mapped property status'
        );

        Test.startTest();

        testProperty.Status__c = newStatusToTest;
        update testProperty;

        Test.stopTest();

        List<Property__c> updatedProperties = TestDataFactory.queryAllTestPropertiesWithRelatedCampaigns();

        System.Assert.areEqual(1, updatedProperties.size());
        System.Assert.areEqual(
            updatedProperties.size(),
            updatedProperties.get(0).Campaigns__r.size()
        );

        Property__c updatedProperty = updatedProperties.get(0);
        String updatedStatus = updatedProperty.Status__c;

        System.Assert.areEqual(
            PropertyCampaignStatusUpdateQueueable.STATUS_MAP.get(updatedStatus),
            updatedProperty.Campaigns__r.get(0).Status,
            'After test campaign status not correctly set according to mapped property status'
        );
        System.Assert.areEqual(
            PropertyCampaignStatusUpdateQueueable.ACTIVE_MAP.get(updatedStatus),
            updatedProperty.Campaigns__r.get(0).IsActive,
            'After test campaign IsActive flag not correctly set according to mapped property status'
        );
    }
    @isTest
    private static void updatePropertyStatus_Bulk() {
        // Bulk property status update testing all Status__c picklist values
        final Integer numTestProperties = 201;
        final String testPropertyStatusValue = 'Contracted';
        final List<String> newStatusesToTest = new List<String>{
            'Pre Market',
            'Available',
            'Under Agreement',
            'Closed'
        };

        List<Property__c> testProperties = TestDataFactory.getPropertiesForTest(
            numTestProperties,
            testPropertyStatusValue
        );

        Boolean eachPropertyHasExactlyOneRelatedCampaign = true;
        for (Property__c thisProperty : testProperties) {
            if (thisProperty.Campaigns__r.size() != 1) {
                eachPropertyHasExactlyOneRelatedCampaign = false;
                break;
            }
        }
        System.Assert.isTrue(
            eachPropertyHasExactlyOneRelatedCampaign,
            'At least one property does not have exactly one related campaign.'
        );

        Boolean allCampaignStatusesMatchMappedPropertyStatuses = true;
        for (Property__c thisProperty : testProperties) {
            String propertyStatus = thisProperty.Status__c;
            if (
                !PropertyCampaignStatusUpdateQueueable.STATUS_MAP.get(
                        propertyStatus
                    )
                    .equals(thisProperty.Campaigns__r.get(0).Status)
            ) {
                allCampaignStatusesMatchMappedPropertyStatuses = false;
                break;
            }
        }
        System.Assert.isTrue(
            allCampaignStatusesMatchMappedPropertyStatuses,
            'At least one campaign status does not match its mapped property status'
        );

        List<Property__c> propertiesToUpdate = new List<Property__c>();
        for (Integer i = 0; i < testProperties.size(); i++) {
            Integer newStatusKey = Math.mod(i, newStatusesToTest.size());
            propertiesToUpdate.add(
                new Property__c(
                    Id = testProperties.get(i).Id,
                    Status__c = newStatusesToTest.get(newStatusKey)
                )
            );
        }

        Test.startTest();
        update propertiesToUpdate;
        Test.stopTest();

        List<Property__c> updatedProperties = TestDataFactory.queryAllTestPropertiesWithRelatedCampaigns();

        System.Assert.areEqual(numTestProperties, updatedProperties.size());

        Boolean postUpdateEachPropertyHasExactlyOneRelatedCampaign = true;
        for (Property__c thisProperty : updatedProperties) {
            if (thisProperty.Campaigns__r.size() != 1) {
                postUpdateEachPropertyHasExactlyOneRelatedCampaign = false;
                break;
            }
        }
        System.Assert.isTrue(
            postUpdateEachPropertyHasExactlyOneRelatedCampaign,
            'After running the trigger at least one property does not have exactly one related campaign.'
        );

        Boolean postUpdateAllCampaignStatusesMatchMappedPropertyStatuses = true;
        for (Property__c thisProperty : updatedProperties) {
            String propertyStatus = thisProperty.Status__c;
            if (
                !PropertyCampaignStatusUpdateQueueable.STATUS_MAP.get(
                        propertyStatus
                    )
                    .equals(thisProperty.Campaigns__r.get(0).Status)
            ) {
                postUpdateAllCampaignStatusesMatchMappedPropertyStatuses = false;
                break;
            }
        }
        System.Assert.isTrue(
            postUpdateAllCampaignStatusesMatchMappedPropertyStatuses,
            'After running the triger at least one campaign status does not match its mapped property status'
        );
    }

    @isTest
    private static void updatePropertyPrice() {
        // When Property Price__c is updated, Campaign ExpectedRevenue value kept in synch
        final Integer numTestProperties = 1;
        final Integer newPriceToTest = 550000;

        List<Property__c> testProperties = TestDataFactory.getPropertiesForTest(
            numTestProperties
        );

        System.Assert.areEqual(1, testProperties.size());
        System.Assert.areEqual(
            testProperties.size(),
            testProperties.get(0).Campaigns__r.size()
        );

        Property__c testProperty = testProperties.get(0);

        System.Assert.areEqual(
            testProperty.Price__c,
            testProperty.Campaigns__r.get(0).ExpectedRevenue
        );

        Test.startTest();

        testProperty.Price__c = newPriceToTest;
        update testProperty;

        Test.stopTest();

        List<Property__c> updatedProperties = TestDataFactory.queryAllTestPropertiesWithRelatedCampaigns();

        System.Assert.areEqual(1, updatedProperties.size());
        System.Assert.areEqual(
            updatedProperties.size(),
            updatedProperties.get(0).Campaigns__r.size()
        );

        Property__c updatedProperty = updatedProperties.get(0);

        System.Assert.areEqual(
            updatedProperty.Price__c,
            updatedProperty.Campaigns__r.get(0).ExpectedRevenue
        );
    }
    @isTest
    private static void updatePropertyPrice_Bulk() {
        // Bulk update property price
        final Integer numTestProperties = 201;

        List<Property__c> testProperties = TestDataFactory.getPropertiesForTest(
            numTestProperties
        );

        Boolean eachPropertyHasExactlyOneRelatedCampaign = true;
        for (Property__c thisProperty : testProperties) {
            if (thisProperty.Campaigns__r.size() != 1) {
                eachPropertyHasExactlyOneRelatedCampaign = false;
                break;
            }
        }
        System.Assert.isTrue(
            eachPropertyHasExactlyOneRelatedCampaign,
            'At least one property does not have exactly one related campaign.'
        );

        Boolean allCampaignsExpectedRevenueMatchMappedPropertyPrice = true;
        for (Property__c thisProperty : testProperties) {
            Decimal propertyPrice = thisProperty.Price__c;
            if (
                propertyPrice !=
                thisProperty.Campaigns__r.get(0).ExpectedRevenue
            ) {
                allCampaignsExpectedRevenueMatchMappedPropertyPrice = false;
                break;
            }
        }
        System.Assert.isTrue(
            allCampaignsExpectedRevenueMatchMappedPropertyPrice,
            'At least one campaign expected revenue does not match its related property price'
        );

        List<Property__c> propertiesToUpdate = new List<Property__c>();
        for (Property__c thisProperty : testProperties) {
            propertiesToUpdate.add(
                new Property__c(
                    Id = thisProperty.Id,
                    Price__c = Math.round(Math.random() * 1000000)
                )
            );
        }

        Test.startTest();
        update propertiesToUpdate;
        Test.stopTest();

        List<Property__c> updatedProperties = TestDataFactory.queryAllTestPropertiesWithRelatedCampaigns();

        System.Assert.areEqual(numTestProperties, updatedProperties.size());

        Boolean postUpdateEachPropertyHasExactlyOneRelatedCampaign = true;
        for (Property__c thisProperty : updatedProperties) {
            if (thisProperty.Campaigns__r.size() != 1) {
                postUpdateEachPropertyHasExactlyOneRelatedCampaign = false;
                break;
            }
        }
        System.Assert.isTrue(
            postUpdateEachPropertyHasExactlyOneRelatedCampaign,
            'After running the trigger at least one property does not have exactly one related campaign.'
        );

        Boolean postUpdateAllCampaignExpectedRevenueMatchMappedPropertyPrice = true;
        for (Property__c thisProperty : updatedProperties) {
            Decimal propertyPrice = thisProperty.Price__c;
            if (
                propertyPrice !=
                thisProperty.Campaigns__r.get(0).ExpectedRevenue
            ) {
                postUpdateAllCampaignExpectedRevenueMatchMappedPropertyPrice = false;
                break;
            }
        }
        System.Assert.isTrue(
            postUpdateAllCampaignExpectedRevenueMatchMappedPropertyPrice,
            'After running the triger at least one campaign expected revenue does not match its related property price'
        );
    }
}
