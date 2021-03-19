MetadataService.ApexPage apexPage = new FlowVFPage()
    .withFlowName('Create_Contact')
    .withVFName('Create_Contact')
    .withVFLabel('Create Contact')
    .withAdditionalParameter('VAR_LeadSource', 'Web')
    .getApexPage();