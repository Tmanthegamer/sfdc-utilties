@isTest
public class FlowVFPageTest {

    @isTest
    private static void prepareContent_withDefaults() {
        String content = new FlowVFPage()
            .withFlowName('My_Test_Flow')
            .prepareContent();

        System.assert(!content.contains('finishLocation="{!$CurrentPage.URL}"'), 'Finish location should not be included');

        String expected = '<apex:page><flow:interview name="My_Test_Flow" ><apex:param name="recordId" value="{!$CurrentPage.parameters.id}"/></flow:interview></apex:page>';
        System.assertEquals(expected, content, 'content did not match the expected');
    }

    @isTest
    private static void prepareContent_reloadOnFinish() {
        Flow.ApexPageAttributes pAttributes = new Flow.ApexPageAttributes();
        pAttributes.reloadOnFinish = true;

        String content = new FlowVFPage()
            .withFlowName('My_Test_Flow')
            .withApexPageAttributes(pAttributes)
            .prepareContent();

        System.assert(content.contains('finishLocation="{!$CurrentPage.URL}"'), 'Finish location was not inputed into the content');

        String expected = '<apex:page><flow:interview name="My_Test_Flow" finishLocation="{!$CurrentPage.URL}"><apex:param name="recordId" value="{!$CurrentPage.parameters.id}"/></flow:interview></apex:page>';
        System.assertEquals(expected, content, 'content did not match the expected');
    }

    @isTest
    private static void prepareContent_withMoreParameters() {

        String content = new FlowVFPage()
            .withFlowName('My_Test_Flow')
            .withAdditionalParameters(new Map<String, String>{
                'VAR_SobjectType' => 'Account',
                'VAR_RecordType' => 'Business'
            })
            .prepareContent();

        System.assert(content.contains('<apex:param name="VAR_SobjectType" value="Account"/>'), 'Flow parameters did not include VAR_SobjectType correctly');
        System.assert(content.contains('<apex:param name="VAR_RecordType" value="Business"/>'), 'Flow parameters did not include VAR_RecordType correctly');
        System.assert(content.contains('<apex:param name="recordId" value="{!$CurrentPage.parameters.id}"/>'), 'Flow parameters did not include recordId correctly');

        String expected = '<apex:page><flow:interview name="My_Test_Flow" >'
            + '<apex:param name="recordId" value="{!$CurrentPage.parameters.id}"/>'
            + '<apex:param name="VAR_SobjectType" value="Account"/>'
            + '<apex:param name="VAR_RecordType" value="Business"/>'
            + '</flow:interview></apex:page>';
        System.assertEquals(expected, content, 'Content did not match the expected');
    }

    @isTest
    private static void buildMetadataPackage_validate_NoFlowName() {
        Exception ex = null;
        try {
            new FlowVFPage().buildMetadataPackage();
        }
        catch(FlowVFPage.FlowVFPageException e) {
            ex = e;
        }
        System.assert(ex != null, 'An exception should have occurred with no supplied flow name');
        System.assertEquals(FlowVFPage.ERROR_FLOW_NAME_MISSING, ex.getMessage(), 'A different exception message occurred');
    }

    @isTest
    private static void buildMetadataPackage_withMoreParameters() {

        MetadataService.ApexPage thePage = new FlowVFPage()
            .withFlowName('My_Test_Flow')
            .withVFName('My_Apex_Page')
            .withVFLabel('My Apex Page')
            .withAdditionalParameters(new Map<String, String>{
                'VAR_SobjectType' => 'Account',
                'VAR_RecordType' => 'Business'
            })
            .buildMetadataPackage()
            .getApexPage();

        System.assertEquals(50, thePage.apiVersion, 'Default API version should be 50');
        System.assertEquals('My_Apex_Page', thePage.fullName, 'thePage.fullName should have taken our given fullName');
        System.assertEquals('My Apex Page', thePage.label, 'thePage.label should have taken our given label');

        String expected = '<apex:page><flow:interview name="My_Test_Flow" >'
            + '<apex:param name="recordId" value="{!$CurrentPage.parameters.id}"/>'
            + '<apex:param name="VAR_SobjectType" value="Account"/>'
            + '<apex:param name="VAR_RecordType" value="Business"/>'
            + '</flow:interview></apex:page>';
        String actual = EncodingUtil.base64Decode(thePage.content).toString();

        System.assertEquals(expected, actual, 'Content did not match the expected');
    }
}
