global with sharing class FlowVFPage {

    /**
     * Base Template for Apex Pages, use in junction with m_baseTemplate
     *
     * {0} = flow name       e.g. Create_POV_Opportunity
     * {1} = finish location
     * {2} = apex parameters
     *
     * example: <flow:interview name="{Create_POV_Opportunity}" finishLocation="/{!$CurrentPage.parameters.id}"><apex:param name="recordId" value="{!Opportunity.Id}"/></flow:interview>
     */
    private static final String BASE_TEMPLATE = '<apex:page><flow:interview name="{0}" {1}">{2}</flow:interview></apex:page>';

    /**
     * Template used to prefill flow parameters, usage described below
     * {0} = parameter name  e.g. recordId
     * {1} = parameter value e.g. {!$CurrentPage.parameters.id}
     *
     * example: <apex:param name="recordId" value="{!{$CurrentPage.parameters.id}"/>
     */
    private static final String PARAMETER_TEMPLATE = '<apex:param name="{0}" value="{!{1}}"/>';

    private PageAttributes m_pageAttributes;
    private FlowAttributes m_flowAttributes;
    private MetadataService.ApexPage m_apexpage;

    global FlowVFPage() {
        this(new PageAttributes(), new FlowAttributes());
    }

    private FlowVFPage(PageAttributes pageAttributes, FlowAttributes flowAttributes) {
        this.m_pageAttributes = pageAttributes;
        this.m_flowAttributes = flowAttributes;
    }

    global FlowVFPage withFlowAttributes(FlowAttributes flowAttributes) {
        this.m_flowAttributes = flowAttributes;
        return this;
    }

    global FlowVFPage withPageAttributes(PageAttributes pageAttributes) {
        this.m_pageAttributes = pageAttributes;
        return this;
    }

    global FlowVFPage withFlowName(String flowName) {
        this.m_flowAttributes.flowName = flowName;
        return this;
    }

    global FlowVFPage withVFName(String fullName) {
        this.m_pageAttributes.fullName = fullName;
        return this;
    }

    global FlowVFPage withVFLabel(String label) {
        this.m_pageAttributes.label = label;
        return this;
    }

    global FlowVFPage buildMetadataPackage() {
        this.m_apexPage = new MetadataService.ApexPage();

        this.m_apexPage.apiVersion = this.m_pageAttributes.apiVersion;
        this.m_apexPage.fullName = this.m_pageAttributes.fullName;
        this.m_apexPage.label = String.isNotBlank(this.m_pageAttributes.label) ? this.m_pageAttributes.label : this.m_pageAttributes.fullName;
        this.m_apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(prepareContent()));

        return this;
    }

    /**
     * Uses the Flow and Page Attributes to generate the content of the apex page
     */
    @TestVisible
    private String prepareContent() {
        String parameters = '';
        if(this.m_flowAttributes.withRecordId) {
            parameters += String.format(PARAMETER_TEMPLATE, new List<String>{'recordId', '{!$CurrentPage.parameters.id}'});
        }

        for(String key : this.m_flowAttributes.additionalParameters.keySet()) {
            String value = this.m_flowAttributes.additionalParameters.get(key);

            parameters += String.format(PARAMETER_TEMPLATE, new List<String>{key, value});
        }

        String finishLocation = '';
        if(this.m_pageAttributes.reloadOnFinish) {
            finishLocation = 'finishLocation="{!$CurrentPage.URL}"';
        }
        String content = String.format(BASE_TEMPLATE, new List<String>{this.m_flowAttributes.flowName, finishLocation, parameters});

        return content;
    }

    public MetadataService.ApexPage getApexPage() {
        if(this.m_apexpage == null) {
            buildMetadataPackage();
        }
        return this.m_apexpage;
    }

    global class PageAttributes {
        global Integer apiVersion = 50;
        global String fullName;
        global String label;
        global Boolean reloadOnFinish = true;
    }

    global class FlowAttributes {
        global Boolean withRecordId = true;
        global Integer apiVersion = 50;
        global String flowName;
        global Map<String, String> additionalParameters = new Map<String, String>();
        global String label;
    }
}
