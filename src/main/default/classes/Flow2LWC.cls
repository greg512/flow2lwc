/**
 * @description Apex class with logic to invoke a Flow and return the output variables
 */
public with sharing class Flow2LWC {
    final String SOBJECT_TYPE = 'sobject';
    final String SOBJECT_LIST_TYPE = 'sobject[]';

    String flowName;
    List<Map<String, Object>> inputVariables;
    List<String> outputVariables;
    Flow.Interview flowInterview;

    Boolean testMode = false;

    /**
     * @description Constructor
     * @param flowName The name of the flow to invoke
     * @param inputVariables The input variables to pass to the flow
     * @param outputVariables The output variables to get from the flow
     * @return `Map<String, Object>` The output variable values
     */
    public Flow2LWC(
        String flowName,
        List<Map<String, Object>> inputVariables,
        List<String> outputVariables
    ) {
        this.flowName = flowName;
        this.inputVariables = inputVariables;
        this.outputVariables = outputVariables;
    }

    /**
     * @description Set the test mode flag
     */
    public void setTestMode() {
        this.testMode = Test.isRunningTest();
    }

    /**
     * @description Start the flow
     */
    public void startInterview() {
        // invoke the flow
        try {
            Map<String, Object> preparedInputVariables = prepareInputVariables();
            if (testMode) {
                // if in test mode, simulate a successful start by returning null
                return;
            }
            flowInterview = Flow.Interview.createInterview(flowName, preparedInputVariables);
            flowInterview.start();
        } catch (TypeException e) {
            String error = e.getMessage();
            // if the flow name is invalid, we'll see a TypeException with a message that ends with the flow name
            if (error.endsWith(flowName)) {
                error =
                    'Could Not Find Flow Named ' +
                    flowName +
                    '. Please Check the Flow Name and Try Again. ' +
                    error;
            }
            throw new Flow2LWCException(error, e);
        } catch (Exception e) {
            // catch any other exception and throw it back to the client
            throw new Flow2LWCException(e);
        }
    }

    /**
     * @description Prepare the input variables for the flow
     * @return `Map<String, Object>` The prepared input variables
     */
    @TestVisible
    private Map<String, Object> prepareInputVariables() {
        if (inputVariables == null) {
            return new Map<String, Object>();
        }
        // iterate through the input variables and prepare them for the flow
        Map<String, Object> result = new Map<String, Object>();
        for (Map<String, Object> inputVar : inputVariables) {
            InputVariable inputVariable = new InputVariable(inputVar);
            // if no value is provided, skip this input variable
            if (inputVariable.value == null) {
                continue;
            }

            // if the input variable is a record, deserialize it into an SObject
            if (inputVariable.inputType?.toLowerCase() == SOBJECT_TYPE) {
                String recordJson = JSON.serialize(inputVariable.value);
                SObject record = (SObject) JSON.deserialize(recordJson, SObject.class);
                result.put(inputVariable.name, record);
                continue;
            }

            // if the input variable is a list of records, deserialize it into a list of SObjects
            if (inputVariable.inputType?.toLowerCase() == SOBJECT_LIST_TYPE) {
                String recordListJson = JSON.serialize(inputVariable.value);
                List<SObject> recordList = (List<SObject>) JSON.deserialize(
                    recordListJson,
                    List<SObject>.class
                );
                result.put(inputVariable.name, recordList);
                continue;
            }

            // if neither an sobject or sobject list, just add the value to the map
            result.put(inputVariable.name, inputVariable.value);
            continue;
        }
        // return the prepared input variables
        return result;
    }

    /**
     * @description Get the output variables from the flow
     * @return  `Map<String, Object>` The output variable values
     */
    public Map<String, Object> getOutputVariableValues() {
        Map<String, Object> result = new Map<String, Object>();
        // if there are no output variables, return an empty map
        if (outputVariables == null || outputVariables.size() == 0) {
            return result;
        }
        // iterate through the output variables and get the values
        for (String outputVariable : outputVariables) {
            if (testMode) {
                // if in test mode, simulate returning the variable name as the value
                result.put(outputVariable, outputVariable);
                continue;
            }
            result.put(outputVariable, flowInterview.getVariableValue(outputVariable));
        }
        return result;
    }

    /**
     * @description Class to represent an input variable
     */
    private class InputVariable {
        public String inputType;
        public String name;
        public Object value;

        /**
         * @description Default Constructor
         * @param inputVar Object representing the input variable
         */
        public InputVariable(Map<String, Object> inputVar) {
            this.inputType = (String) inputVar.get('inputType');
            this.name = (String) inputVar.get('name');
            this.value = inputVar.get('value');
        }
    }

    /**
     * @description Custom Exception Class
     */
    public class Flow2LWCException extends Exception {
    }
}
