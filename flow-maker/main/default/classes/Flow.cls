/**
 * Class that contains various Data Classes to be leveraged by the FlowMaker to
 * generate Visualforce Pages or Lightning Components that will call Flows
 */
global class Flow {

    /**
     * Data class, represents the Page Attributes pertaining a soon to be generated Visualforce Page
     */
    global class ApexPageAttributes {
        global Integer apiVersion = 50;
        global String fullName;
        global String label;
        global Boolean reloadOnFinish = false;
    }

    /**
     * Data class, represents the Flow Attributes that will become part of the Visualforce Page's contents
     */
    global class FlowAttributes {
        global Boolean withRecordId = true;
        global Integer apiVersion = 50;
        global String flowName;
        global Map<String, String> additionalParameters = new Map<String, String>();
        global String label;
    }

}
