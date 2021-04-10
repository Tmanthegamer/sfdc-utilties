public class SObjectValue {

    private Boolean hasValue = false;

    public SObject retVal;
    public String finalField;
    public SObjectStamperConstants.DataType retType;
    public Object value {
        get {
            if(!this.hasValue && retVal != null) {
                this.value = retVal.get(finalField);
                this.hasValue = true;
            }
            else {
                this.value = null;
            }
            return this.value;
        }
        set;
    }

    public SObjectValue(SObject retVal, String finalField, SObjectStamperConstants.DataType retType) {
        this.retVal = retVal;
        this.finalField = finalField;
        this.retType = retType;
    }
}
