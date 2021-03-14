global with sharing class FlowMaker {

    global static Response createVFPage() {
        // Define Metadata item to create a Visualforce page to display the above field
        MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
        apexPage.apiVersion = 50;
        apexPage.fullName = objectName.toLowercase();
        apexPage.label = objectName + ' Page';
        apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(
            '<apex:page>'+
                '{!' + objectName + '__c.TestField1__c}' +
                '{!' + objectName + '__c.TestField2__c}' +
            '</apex:page>'));

        // Create components in the correct order
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customObject });
        handleSaveResults(results[0]);
        results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField1, customField2 });
        handleSaveResults(results[0]);
        handleSaveResults(results[1]);
        results =
            service.createMetadata(
                new MetadataService.Metadata[] { apexPage });
        handleSaveResults(results[0]);
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    private static void handleSaveResults(MetadataService.SaveResult saveResult, Response resp)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success) {
            return;
        }

        if(!saveResult.success && saveResult.errors == null) {
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
        }
        String message = saveResult.errors.size()==1
            ? 'Error '
            : 'Errors '
            + 'occured processing component ' + saveResult.fullName + '.';

        // Construct error message and throw an exception
        List<String> messages = new List<String>{message};

        for(MetadataService.Error error : saveResult.errors) {
            messages.add(
                error.message + ' (' + error.statusCode + ').' +
                ( error.fields!=null && error.fields.size()>0 ?
                    ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
        }
        throw new MetadataServiceExamplesException(String.join(messages, ' '));
    }
}
