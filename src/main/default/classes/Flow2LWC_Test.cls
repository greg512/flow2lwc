/**
 * @description Test class for Flow2LWC
 */
@IsTest
private with sharing class Flow2LWC_Test {
    static final String OUTPUT_VAR = 'testVar';
    static final String FLOW_NAME = 'testFlowWBadName';
    static final Map<String, Object> TEST_INPUT_VAR = new Map<String, Object>{
        'name' => 'inputVarName',
        'value' => 'inputVarValue'
    };
    static final Map<String, Object> RECORD_ATTRIBUTES_VALUE = new Map<String, Object>{
        'type' => 'Account'
    };
    static final Map<String, Object> RECORD_INPUT_VAR = new Map<String, Object>{
        'name' => 'recordInput',
        'inputType' => 'SObject',
        'value' => new Map<String, Object>{
            'Name' => 'Test Account',
            'attributes' => RECORD_ATTRIBUTES_VALUE
        }
    };

    @isTest
    static void itShouldInvokeFlow() {
        List<Map<String, Object>> inputVariables = new List<Map<String, Object>>();
        List<String> outputVariables = new List<String>();

        // set a test input var
        inputVariables.add(TEST_INPUT_VAR);

        // set a test output var
        outputVariables.add(OUTPUT_VAR);

        Test.startTest();
        Flow2LWC f2l = new Flow2LWC(FLOW_NAME, inputVariables, outputVariables);
        f2l.setTestMode();
        f2l.startInterview();
        Map<String, Object> result = f2l.getOutputVariableValues();
        Test.stopTest();

        // The ouput variable should be available in the result map
        System.assertEquals(
            OUTPUT_VAR,
            (String) result.get(OUTPUT_VAR),
            'Expected variable value does not match actual value.'
        );
    }

    @isTest
    static void itShouldSerializeSobjectInput() {
        List<Map<String, Object>> inputVariables = new List<Map<String, Object>>();
        List<String> outputVariables = new List<String>();

        // set a test record input var
        inputVariables.add(RECORD_INPUT_VAR);

        // set a test output var
        outputVariables.add(OUTPUT_VAR);

        Test.startTest();
        Flow2LWC f2l = new Flow2LWC(FLOW_NAME, inputVariables, outputVariables);
        f2l.setTestMode();
        f2l.startInterview();
        Map<String, Object> result = f2l.getOutputVariableValues();
        Test.stopTest();

        // The ouput variable should be available in the result map
        System.assertEquals(
            OUTPUT_VAR,
            (String) result.get(OUTPUT_VAR),
            'Expected variable value does not match actual value.'
        );
    }

    @isTest
    static void itShouldFailWithBadName() {
        List<Map<String, Object>> inputVariables = new List<Map<String, Object>>();
        List<String> outputVariables = new List<String>();

        // set a test input var
        inputVariables.add(TEST_INPUT_VAR);

        // set a test output var
        outputVariables.add(OUTPUT_VAR);

        Test.startTest();
        Boolean itFailed = false;
        try {
            Flow2LWC f2l = new Flow2LWC(FLOW_NAME, inputVariables, outputVariables);
            f2l.startInterview();
        } catch (Flow2LWC.Flow2LWCException e) {
            itFailed = e.getMessage().startsWith('Could Not Find Flow Named');
        }
        Test.stopTest();

        System.assert(itFailed, 'It should have failed with a bad flow name.');
    }

    @isTest
    static void itShouldInvokeFlow2LWCFromController() {
        List<Map<String, Object>> inputVariables = new List<Map<String, Object>>();
        List<String> outputVariables = new List<String>();

        // set a test input var
        inputVariables.add(TEST_INPUT_VAR);

        // set a test output var
        outputVariables.add(OUTPUT_VAR);

        Test.startTest();
        Boolean controllerMethodSucceeded = false;
        try {
            Flow2LWCController.invokeFlow(FLOW_NAME, inputVariables, outputVariables);
        } catch (AuraHandledException e) {
            // this will always fail while testing because we don't have a flow in this app
            // instead, check that the controller method did its job and it failed in the expected way
            controllerMethodSucceeded = true;
        }
        Test.stopTest();

        System.assert(controllerMethodSucceeded, 'The controller method should have done its job.');
    }
}
