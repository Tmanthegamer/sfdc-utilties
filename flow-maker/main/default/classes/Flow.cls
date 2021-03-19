/**
 * Class that contains various Data Classes to be leveraged by the FlowMaker to
 * generate Visualforce Pages or Lightning Components that will call Flows
 */
global virtual class Flow {

    public static final String ERROR_FLOW_NAME_MISSING = 'Flow name not specified';

    protected MetadataService.Metadata m_metadata;
    protected Flow.FlowAttributes m_flowAttributes;

    /**
     * @description Constructor for the Flow class
     * @return                  Flow
     */
    public Flow() {
        this(new Flow.FlowAttributes());
    }

    /**
     * @description Constructor for the Flow class
     * @param  m_flowAttributes Flow Attributes to be used when creating flows
     * @return                  Flow
     */
    public Flow(Flow.FlowAttributes m_flowAttributes) {
        this.m_flowAttributes = m_flowAttributes;
    }

    /**
     * @description Builds the Metadata Package for use with MetadataService with
     * earlier defined Page and VF Attributes. Throws validation errors if some
     * information is missing
     * @return   ApexPage to be used with MetadataService
     */
    protected MetadataService.Metadata getMetadata() {
        if(this.m_metadata == null) {
            buildMetadataPackage();
        }
        return this.m_metadata;
    }

    /**
     * @description Set the Flow.FlowAttributes and return the FlowVFPage for method chaining
     * @param  Flow.FlowAttributes Pre-constructed Flow.FlowAttributes object
     * @return                this, used for method chaining
     */
    public Flow withFlowAttributes(Flow.FlowAttributes flowAttributes) {
        this.m_flowAttributes = flowAttributes;
        return this;
    }

    /**
     * @description Set the Flow's name and return the FlowVFPage for method chaining
     * @param  flowName API Name of the Flow
     * @return          this, used for method chaining
     */
    public Flow withFlowName(String flowName) {
        this.m_flowAttributes.fullName = flowName;
        return this;
    }

    /**
     * @description Sets a key/value pair for the Flow Parameters to be generated
     * by the content. Can be used for method chaining
     * @param  key   Flow Variable Input
     * @param  value Flow Variable Input's value
     * @return       this, can be used for method chaining
     */
    public Flow withAdditionalParameter(String key, String value) {
        this.m_flowAttributes.additionalParameters.put(key, value);
        return this;
    }

    /**
     * @description Sets many key/value for the Flow Parameters to be generated
     * by the content. Can be used for method chaining
     * @param  values Map<String, String> to be put into the Flow Variable input and values
     * @return        this, can be used for method chaining
     */
    public Flow withAdditionalParameters(Map<String, String> values) {
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
    protected virtual Flow buildMetadataPackage() { throw new Flow.FlowException('Not Implemented'); }

    /**
     * @description Validates all of the inputs to ensure tha the Metadata generation has
     * the best chance to succeed.
     * @return content to be used for the Apex Page
     */
    @TestVisible
    protected String validate() {
        List<String> errors = new List<String>();
        if(String.isBlank(this.m_flowAttributes.fullName)) {
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
    protected String formattedTemplate(String template, List<String> values) {
        for(Integer i = 0; i < values.size(); i++) {
            String index = '{'+i+'}';
            template = template.replace(index, values[i]);
        }
        return template;
    }

    public virtual class Attributes {
        public Integer apiVersion = 50;
        public String fullName;
        public String label;
    }

    global virtual class Request {
        global String flowName;
        global String apiName;
        global Integer apiVersion = 50;
    }

    /**
     * Data class, represents the Page Attributes pertaining a soon to be generated Visualforce Page
     */
    public class ApexPageAttributes extends Attributes {
        public Boolean reloadOnFinish = false;
    }

    /**
     * Data class, represents the Flow Attributes that will become part of the Visualforce Page's contents
     */
    public class FlowAttributes extends Attributes {
        public Boolean withRecordId = true;
        public Map<String, String> additionalParameters = new Map<String, String>();
    }

    /** Flow Exception */
    public class FlowException extends Exception {}

}
