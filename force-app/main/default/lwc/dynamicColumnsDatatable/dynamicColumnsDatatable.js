import { LightningElement, wire, track } from "lwc";

import getOpportunitiesWithColumns from "@salesforce/apex/DynamicColumnsDatatableCtrl.getOpportunitiesWithColumns";

export default class DynamicColumnsDatatable extends LightningElement {
    // columns config for datatable
    @track columns = [];

    // data
    @track opportunities = [];

    @wire(getOpportunitiesWithColumns)
    getOpportunitiesWithColumnsWired({ error, data }) {
        if (error) {
            console.error(
                "Error getting opportunities and column config",
                error
            );
        } else if (data) {
            console.log("columnsInfo", JSON.stringify(data.columnsInfo));
            this.columns = data.columnsInfo.map((col) => ({
                label: col.Field_Label__c,
                fieldName: col.Field_Api__c,
                type: col.Data_Type__c || "text",
                initialWidth: col.Initial_Width__c,
                // if any additional column info provided in JSON.
                ...this.getAdditionalColumnInfo(col.Additional_Props_JSON__c)
            }));

            this.opportunities = data.data;
        }
    }

    getAdditionalColumnInfo(json) {
        if (!json) return {};
        try {
            return JSON.parse(json);
        } catch (e) {
            console.error("error while parsing additional column info", e);
            return {};
        }
    }
}
