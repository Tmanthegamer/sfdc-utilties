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
global with sharing class FlowVFPage {

    public static final String ERROR_FLOW_NAME_MISSING = 'Flow name not specified';

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
    private Flow.FlowAttributes m_flowAttributes;
    private MetadataService.ApexPage m_apexpage;

    /**
     * @description Global Constructor for FlowVFPage
     * @return   new FlowVFPage, can leverage other methods for method chaining
     */
    global FlowVFPage() {
        this(new Flow.ApexPageAttributes(), new Flow.FlowAttributes());
    }

    /**
     * @description Private Constructor for the FlowVFPage
     * @param  Flow.ApexPageAttributes Visualforce Page Attributes used for generate Apex Pages
     * @param  Flow.FlowAttributes Flow specific Attributes used for the content of Apex Pages
     * @return                return description
     */
    private FlowVFPage(Flow.ApexPageAttributes pageAttributes, Flow.FlowAttributes flowAttributes) {
        this.m_pageAttributes = pageAttributes;
        this.m_flowAttributes = flowAttributes;
    }

    /**
     * @description Set the Flow.FlowAttributes and return the FlowVFPage for method chaining
     * @param  Flow.FlowAttributes Pre-constructed Flow.FlowAttributes object
     * @return                this, used for method chaining
     */
    global FlowVFPage withFlowAttributes(Flow.FlowAttributes flowAttributes) {
        this.m_flowAttributes = flowAttributes;
        return this;
    }

    /**
     * @description Set the Visualforce Page Attributes and return the FlowVFPage for method chaining
     * @param  Flow.ApexPageAttributes Pre-constructed Flow.ApexPageAttributes object
     * @return                this, used for method chaining
     */
    global FlowVFPage withApexPageAttributes(Flow.ApexPageAttributes pageAttributes) {
        this.m_pageAttributes = pageAttributes;
        return this;
    }

    /**
     * @description Set the Flow's name and return the FlowVFPage for method chaining
     * @param  flowName API Name of the Flow
     * @return          this, used for method chaining
     */
    global FlowVFPage withFlowName(String flowName) {
        this.m_flowAttributes.flowName = flowName;
        return this;
    }

    /**
     * @description Set the Visualforce Page's name
     * @param  fullName Name of the Visualforce page
     * @return          this, used for method chaining
     */
    global FlowVFPage withVFName(String fullName) {
        this.m_pageAttributes.fullName = fullName;
        return this;
    }

    /**
     * @description Set the Visualforce Page's friendly label
     * @param  label Friendly Label when viewing the Visualforce Page
     * @return       this, used for method chaining
     */
    global FlowVFPage withVFLabel(String label) {
        this.m_pageAttributes.label = label;
        return this;
    }

    /**
     * @description Sets a key/value pair for the Flow Parameters to be generated
     * by the content. Can be used for method chaining
     * @param  key   Flow Variable Input
     * @param  value Flow Variable Input's value
     * @return       this, can be used for method chaining
     */
    global FlowVFPage withAdditionalParameter(String key, String value) {
        this.m_flowAttributes.additionalParameters.put(key, value);
        return this;
    }

    /**
     * @description Sets many key/value for the Flow Parameters to be generated
     * by the content. Can be used for method chaining
     * @param  values Map<String, String> to be put into the Flow Variable input and values
     * @return        this, can be used for method chaining
     */
    global FlowVFPage withAdditionalParameters(Map<String, String> values) {
        for(String key : values.keySet()) {
            withAdditionalParameter(key, values.get(key));
        }
        return this;
    }

    /**
     * @description Builds the MetadataService.ApexPage and gets it ready to be
     * used by the MetadataService to create the Visualforce Page
     * @return   this, can be used for method chaining
     */
    global FlowVFPage buildMetadataPackage() {
        this.m_apexPage = new MetadataService.ApexPage();

        String errorMsg = validate();
        if(String.isNotBlank(errorMsg)) {
            throw new FlowVFPageException(errorMsg);
        }

        this.m_apexPage.apiVersion = this.m_pageAttributes.apiVersion;
        this.m_apexPage.fullName = this.m_pageAttributes.fullName;
        this.m_apexPage.label = String.isNotBlank(this.m_pageAttributes.label) ? this.m_pageAttributes.label : this.m_pageAttributes.fullName;
        this.m_apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(prepareContent()));

        return this;
    }

    /**
     * @description Validates all of the inputs to ensure tha the Metadata generation has
     * the best chance to succeed.
     * @return content to be used for the Apex Page
     */
    @TestVisible
    private String validate() {
        List<String> errors = new List<String>();
        if(String.isBlank(this.m_flowAttributes.flowName)) {
            errors.add(ERROR_FLOW_NAME_MISSING);
        }

        return String.join(errors, '\n');
    }

    /**
     * @description Given a template and a map of values, it will replace each of the {#}
     * slots with the given list of values. Couldn't have used String.format because the
     * method doesn't like having curly braces as part of the values
     * @param  template Template String with "{0}" or other numbers inside
     * @param  values   List of values to be used as replacements
     * @return          Formated template string with each "{0}" replaced with the value from the list
     */
    private static String formattedTemplate(String template, List<String> values) {
        for(Integer i = 0; i < values.size(); i++) {
            String index = '{'+i+'}';
            template = template.replace(index, values[i]);
        }
        return template;
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

        String content = formattedTemplate(BASE_TEMPLATE, new List<String>{this.m_flowAttributes.flowName, finishLocation, parameters});

        return content;
    }

    /**
     * @description Builds the Metadata Package for use with MetadataService with
     * earlier defined Page and VF Attributes. Throws validation errors if some
     * information is missing
     * @return   ApexPage to be used with MetadataService
     */
    public MetadataService.ApexPage getApexPage() {
        if(this.m_apexpage == null) {
            buildMetadataPackage();
        }
        return this.m_apexpage;
    }

    /** Exception class used when validations fail */
    global class FlowVFPageException extends Exception{}
}
