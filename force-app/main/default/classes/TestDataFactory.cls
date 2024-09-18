public with sharing class TestDataFactory {
    private static String DEFAULT_STATUS_VALUE = 'Contracted';
    // public TestDataFactory() {

    // }

    public static void createProperties(Integer amount) {
        createProperties(amount, DEFAULT_STATUS_VALUE);
    }

    public static void createProperties(Integer amount, String status) {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < amount; i++) {
            properties.add(
                new Property__c(
                    Name = 'Name ' + i,
                    Price__c = 20000,
                    Beds__c = 3,
                    Baths__c = 3,
                    Status__c = status
                )
            );
        }
        insert properties;
    }

    public static List<Property__c> getPropertiesForTest(Integer num) {
        return getPropertiesForTest(num, DEFAULT_STATUS_VALUE);
    }

    public static List<Property__c> getPropertiesForTest(
        Integer num,
        String status
    ) {
        List<Property__c> propsToTest = new List<Property__c>();

        createProperties(num, status);

        propsToTest = queryAllTestPropertiesWithRelatedCampaigns();

        return propsToTest;
    }

    public static List<Property__c> queryAllTestPropertiesWithRelatedCampaigns() {
        return [
            SELECT
                Id,
                Name,
                Status__c,
                Price__c,
                (
                    SELECT Id, Name, Status, ExpectedRevenue, IsActive
                    FROM Campaigns__r
                )
            FROM Property__c
        ];
    }
}
