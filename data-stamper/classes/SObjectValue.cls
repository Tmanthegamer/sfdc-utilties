public class SObjectValue {

    public SObject retVal;
    public Object value;
    public String finalField;
    public SObjectStamperConstants.DataType retType;

    private Boolean hasValue = false;

    public SObjectValue(SObject retVal, String finalField, SObjectStamperConstants.DataType retType) {
        this.retVal = retVal;
        this.finalField = finalField;
        this.retType = retType;
    }

    public Object getValue() {
        if(!hasValue) {
            this.value = retVal.get(finalField);
            hasValue = true;
        }
        return this.value;
    }
}
