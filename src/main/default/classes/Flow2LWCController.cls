/**
 * @description Flow2LWC controller class with AuraEnabled method to invoke a Flow
 */
public with sharing class Flow2LWCController {
    /**
     * @description Invoke a Flow
     * @param flowName The name of the flow to invoke
     * @param inputVariables The input variables to pass to the flow
     * @param outputVariables The output variables to get from the flow
     * @return `Map<String, Object>` The output variable values
     */
    @AuraEnabled
    public static Map<String, Object> invokeFlow(
        String flowName,
        List<Map<String, Object>> inputVariables,
        List<String> outputVariables
    ) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            // invoke the flow
            Flow2LWC f2lwc = new Flow2LWC(flowName, inputVariables, outputVariables);
            f2lwc.startInterview();
            // get the output variables
            result = f2lwc.getOutputVariableValues();
        } catch (Exception e) {
            // catch the exception and throw an AuraHandledException
            String errorMessage = e.getMessage();
            throw new AuraHandledException(errorMessage);
        }
        return result;
    }
}
