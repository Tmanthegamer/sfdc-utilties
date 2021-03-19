global with sharing class FlowMaker {

    global static FlowMakerResponse createVFPage() {

        FlowMakerResponse res = new FlowMakerResponse();
        try {
            MetadataService.ApexPage apexPage = new FlowVFPage()
                .withFlowName('Create_Contact')
                .withVFName('Create_Contact')
                .withVFLabel('Create Contact')
                .withAdditionalParameter('VAR_LeadSource', 'Web')
                .getApexPage();

            MetadataService.MetadataPort service = createService();

            List<MetadataService.SaveResult> results =
                service.createMetadata(
                    new MetadataService.Metadata[] { apexPage });
            handleSaveResults(results[0], res);

            res.message = 'Success';
            res.success = true;
        }
        catch(Exception ex) {
            res.success = false;
        }
        return res;
    }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    private static void handleSaveResults(MetadataService.SaveResult saveResult, FlowMakerResponse resp)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success) {
            return;
        }

        if(!saveResult.success && saveResult.errors == null) {
            throw new Flow.FlowException('Request failed with no specified error.');
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
        throw new Flow.FlowException(String.join(messages, ' '));
    }

    global class FlowMakerRequest {

    }
    global class FlowMakerResponse extends Response {

    }
}
