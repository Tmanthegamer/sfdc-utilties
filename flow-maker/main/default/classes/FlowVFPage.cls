/**
 * Apex Class dedicated to generating Visualforce Pages that hook in flows and leverages the builder pattern
 * to allow for method chaining.
 *
 * Example Usage:
 * MetadataService.ApexPage thePage = new FlowVFPage()
 *  .withFlowName('My_Test_Flow')
 *  .withVFName('My_Apex_Page')
 *  .withVFLabel('My Apex Page')
 *  .withAdditionalParameters(new Map<String, String>{
 *      'VAR_SobjectType' => 'Account',
 *      'VAR_RecordType' => 'Business'
 *  })
 *  .buildMetadataPackage()
 *  .getApexPage();
 */
public with sharing class FlowVFPage extends Flow {

    /**
     * Base Template for Apex Pages, use in junction with m_baseTemplate
     *
     * {0} = flow name       e.g. Create_POV_Opportunity
     * {1} = finish location
     * {2} = apex parameters
     *
     * example: <flow:interview name="{Create_POV_Opportunity}" finishLocation="/{!$CurrentPage.parameters.id}"><apex:param name="recordId" value="{!Opportunity.Id}"/></flow:interview>
     */
    private static final String BASE_TEMPLATE = '<apex:page><flow:interview name="{0}" {1}>{2}</flow:interview></apex:page>';

    /**
     * Template used to prefill flow parameters, usage described below
     * {0} = parameter name  e.g. recordId
     * {1} = parameter value e.g. {!$CurrentPage.parameters.id}
     *
     * example: <apex:param name="recordId" value="{!{$CurrentPage.parameters.id}"/>
     */
    private static final String PARAMETER_TEMPLATE = '<apex:param name="{0}" value="{1}"/>';

    private Flow.ApexPageAttributes m_pageAttributes;
    private MetadataService.ApexPage m_apexpage;

    /**
     * @description public Constructor for FlowVFPage
     * @return   new FlowVFPage, can leverage other methods for method chaining
     */
    public FlowVFPage() {
        this(new Flow.ApexPageAttributes(), new Flow.FlowAttributes());
    }

    /**
     * @description Private Constructor for the FlowVFPage
     * @param  Flow.ApexPageAttributes Visualforce Page Attributes used for generate Apex Pages
     * @param  Flow.FlowAttributes Flow specific Attributes used for the content of Apex Pages
     * @return                return description
     */
    private FlowVFPage(Flow.ApexPageAttributes pageAttributes, Flow.FlowAttributes flowAttributes) {
        super(flowAttributes);
        this.m_pageAttributes = pageAttributes;
    }

    /**
     * @description Set the Visualforce Page Attributes and return the FlowVFPage for method chaining
     * @param  Flow.ApexPageAttributes Pre-constructed Flow.ApexPageAttributes object
     * @return                this, used for method chaining
     */
    public FlowVFPage withApexPageAttributes(Flow.ApexPageAttributes pageAttributes) {
        this.m_pageAttributes = pageAttributes;
        return this;
    }

    /**
     * @description Set the Visualforce Page's name
     * @param  fullName Name of the Visualforce page
     * @return          this, used for method chaining
     */
    public FlowVFPage withVFName(String fullName) {
        this.m_pageAttributes.fullName = fullName;
        return this;
    }

    /**
     * @description Set the Visualforce Page's friendly label
     * @param  label Friendly Label when viewing the Visualforce Page
     * @return       this, used for method chaining
     */
    public FlowVFPage withVFLabel(String label) {
        this.m_pageAttributes.label = label;
        return this;
    }

    /**
     * @description Builds the MetadataService.ApexPage and gets it ready to be
     * used by the MetadataService to create the Visualforce Page
     * @return   this, can be used for method chaining
     */
    protected override Flow buildMetadataPackage() {
        MetadataService.ApexPage apexPage = new MetadataService.ApexPage();

        String errorMsg = validate();
        if(String.isNotBlank(errorMsg)) {
            throw new Flow.FlowException(errorMsg);
        }

        apexPage.apiVersion = this.m_pageAttributes.apiVersion;
        apexPage.fullName = this.m_pageAttributes.fullName;
        apexPage.label = String.isNotBlank(this.m_pageAttributes.label) ? this.m_pageAttributes.label : this.m_pageAttributes.fullName;
        apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(prepareContent()));

        this.m_metadata = (MetadataService.Metadata) apexPage;
        return this;
    }

    /**
     * @description Uses the Flow and Page Attributes to generate the content of the Visualforce Page.
     * @return   Body of the Visualforce Page
     */
    @TestVisible
    private String prepareContent() {
        String parameters = '';
        if(this.m_flowAttributes.withRecordId) {
            parameters += formattedTemplate(PARAMETER_TEMPLATE, new List<String>{'recordId', '{!$CurrentPage.parameters.id}'});
        }

        this.m_flowAttributes.additionalParameters.remove(null);
        this.m_flowAttributes.additionalParameters.remove('');
        for(String key : this.m_flowAttributes.additionalParameters.keySet()) {
            String value = this.m_flowAttributes.additionalParameters.get(key);

            parameters += formattedTemplate(PARAMETER_TEMPLATE, new List<String>{key, value});
        }

        String finishLocation = '';
        if(this.m_pageAttributes.reloadOnFinish) {
            finishLocation = 'finishLocation="{!$CurrentPage.URL}"';
        }

        String content = formattedTemplate(BASE_TEMPLATE, new List<String>{this.m_flowAttributes.fullName, finishLocation, parameters});

        return content;
    }

    /**
     * @description Builds the Metadata Package for use with MetadataService with
     * earlier defined Page and VF Attributes. Throws validation errors if some
     * information is missing
     * @return   ApexPage to be used with MetadataService
     */
    public MetadataService.ApexPage getApexPage() {
        return (MetadataService.ApexPage) getMetadata();
    }

    /** Exception class used when validations fail */
    public class FlowVFPageException extends Exception{}
}
