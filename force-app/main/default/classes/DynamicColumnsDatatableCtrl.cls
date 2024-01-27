/**
 * @description - Sample code for Lightning Datatable with dynamic columns. Columns config is stored in custom metadata.
 * @author Rahul Gawale
 * @createdAt - 2024-01-27
 */

public with sharing class DynamicColumnsDatatableCtrl {
    /**
     * @description - this function fetches the dynamic column metadata information
     * @param groupName - group name of the fields to display.
     * @return - Returns list of Datatable_Column__mdt records with specified groupName.
     */
    public static List<Datatable_Column__mdt> getColumnMetadata(
        String groupName
    ) {
        return [
            SELECT
                Field_Label__c,
                Field_Api__c,
                Data_Type__c,
                Initial_Width__c,
                Custom_Type_Name__c,
                Additional_Props_JSON__c,
                Order__c
            FROM Datatable_Column__mdt
            WHERE Group__c = :groupName
            ORDER BY Order__c
        ];
    }

    /**
     * @description - fetch opportunities to show in the datatable.
     */
    @AuraEnabled(cacheable=true)
    public static DatableConfigWrapper getOpportunitiesWithColumns() {
        // get the column config.
        List<Datatable_Column__mdt> columns = getColumnMetadata('Opportunity');

        List<String> fields = new List<String>();
        for (Datatable_Column__mdt col : columns) {
            // Validate if the field API name is not null or empty
            if (
                String.isNotBlank(col.Field_Api__c) &&
                isFieldValid('Opportunity', col.Field_Api__c.trim())
            ) {
                // Add the field API name to the list
                fields.add(col.Field_Api__c);
            }
        }

        String query = 'SELECT ';
        if (fields.isEmpty()) {
            // If no valid fields found, query all fields
            query += 'Id, Name, StageName, CloseDate FROM Opportunity';
        } else {
            // Build the query using the valid fields
            query += String.join(fields, ', ') + ' FROM Opportunity';
        }

        query += ' LIMIT 10';

        // Add any additional conditions or order by clauses as needed
        // For example: query += ' WHERE StageName = \'Closed\' ORDER BY CloseDate DESC';

        // Execute the query and return the results
        List<Opportunity> opportunities = Database.query(query);

        DatableConfigWrapper wrapper = new DatableConfigWrapper();
        wrapper.data = opportunities;
        wrapper.columnsInfo = columns;
        return wrapper;
    }

    /**
     * @description wrapper for returning data and column config for Lightning datatable.
     */
    public class DatableConfigWrapper {
        @AuraEnabled
        public List<SObject> data { get; set; }
        @AuraEnabled
        public List<Datatable_Column__mdt> columnsInfo { get; set; }
    }

    /**
     * @description - Check if a field exists on an object.
     * @param objectApiName - API name of the object.
     * @param fieldApiName - API name of the field.
     * @return - Returns true if the field exists, otherwise false.
     */
    private static Boolean isFieldValid(
        String objectApiName,
        String fieldApiName
    ) {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
            .get(objectApiName)
            .getDescribe()
            .fields.getMap();
        return fieldMap.containsKey(fieldApiName);
    }
}
