# flow2lwc

Flow2lwc is a lightweight tool built for the Salesforce Platform that allows you to seemlessly invoke Autolaunched Flows from Lightning Web Components and retrieve the Flow's output variables.

## Who Should Use This?

Salesforce Developers building Lightning Web Components who want to declaritvely define back-end logic with Flows and
avoid creating new Apex controller classes and test classes.

## Installation

Grab the code from [here](https://github.com/greg512/flow2lwc/tree/feature/initial-build/src/main/default/classes) or deploy the code to your Salesforce org:

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=greg512&repo=flow2lwc)

## Usage

Import the utility method to your LWC and invoke a flow by passing in the flow API name:

```javascript
import { LightningElement } from "lwc";

// import the apex method
import invokeFlow from "@salesforce/apex/Flow2LWCController.invokeFlow";

export default class LwcWithFlowData extends LightningElement {
    connectedCallback() {
        // invoke the flow
        invokeFlow({ flowName: "MyFlowAPIName" })
            .then((result) => {
                // Handle the result
            })
            .catch((error) => {
                // Handle the error
            });
    }
}
```

### Set Flow Input Variables

If your Flow requires input variables, you can provide them as an array of objects in the inputVariables property.

```javascript
invokeFlow({
    flowName: "MyFlowAPIName",
    inputVariables: [
        { name: "var1", value: "Hello" },
        { name: "var2", value: 234.23 }
    ]
});
```

If the Flow input variable type is a record or a collection of records, set the `inputType` property on the object and set it to `SObject` or `SObject[]` respectively. Additionally, the object that repesents the record must include an `attributes` property with the `type` property set to the object API name. For example:

```javascript
invokeFlow({
    flowName: "MyFlowAPIName",
    inputVariables: [
        // example Account record input variable
        {
            name: "singleRecordVariable",
            inputType: "SObject",
            value: {
                attributes: {
                    type: "Account"
                },
                Name: "My Account",
                BillingStreet: "123 Main St",
                BillingCity: "San Francisco",
                BillingState: "CA",
                BillingPostalCode: "94105",
                BillingCountry: "USA"
            }
        },
        // example collection of Account records input variable
        {
            name: "recordCollectionVariable",
            inputType: "SObject[]",
            value: [
                {
                    attributes: {
                        type: "Account"
                    },
                    Name: "My Other Account"
                }
            ]
        }
    ]
});
```

### Retrieve Flow Output Variables

To retrieve the Flow's output variables, set the `outputVariables` property to an array of the output variable names. For example:

```javascript
const inputParams = {
    flowName: "MyFlowAPIName",
    inputVariables: [
        // ...
    ],
    outputVariables: ["OutputVariableName", "OutputVariableName2"]
};

invokeFlow(inputParams)
    .then((result) => {
        // Handle the result
        const outputVariableValue = result.OutputVariableName;
        const outputVariableValue2 = result.OutputVariableName2;
    })
    .catch((error) => {
        // Handle the error
    });
```
