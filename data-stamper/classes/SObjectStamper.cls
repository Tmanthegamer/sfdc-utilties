public without sharing class SObjectStamper {

    // Allows for mocking behaviour
    @TestVisible private static List<SObject_Stamper__mdt> mockRecords;

    private static final List<SObject_Stamper__mdt> STAMPER_RECORDS {
        get {
            if(STAMPER_RECORDS == null) {
                STAMPER_RECORDS = mockRecords != null ? mockRecords : SObject_Stamper__mdt.getAll().values();
            }
            return STAMPER_RECORDS;
        }
        set;
    }

    private static final Map<SObjectType, List<SObject_Stamper__mdt>> STAMPER_MAP {
        get {
            if(STAMPER_MAP == null) {
                STAMPER_MAP = new Map<SObjectType, List<SObject_Stamper__mdt>>();
                for(SObject_Stamper__mdt record : STAMPER_RECORDS) {
                    SObjectType sobjType = ((SObject)(Type.forName('Schema.'+record.SObject__c).newInstance())).getSObjectType();
                    if(!STAMPER_MAP.containsKey(sobjType)) {
                        STAMPER_MAP.put(sobjType, new List<SObject_Stamper__mdt>());
                    }

                    if(record.Active__c) {
                        STAMPER_MAP.get(sobjType).add(record);
                    }
                }
            }
            return STAMPER_MAP;
        }
        set;
    }

    private static final Map<SObjectType, Set<String>> STAMPER_FIELDS {
        get {
            if(STAMPER_FIELDS == null) {
                STAMPER_FIELDS = new Map<SObjectType, Set<String>>();
                for(SObject_Stamper__mdt record : STAMPER_RECORDS) {
                    SObjectType sobjType = ((SObject)(Type.forName('Schema.'+record.SObject__c).newInstance())).getSObjectType();
                    if(!STAMPER_FIELDS.containsKey(sobjType)) {
                        STAMPER_FIELDS.put(sobjType, new Set<String>());
                    }
                    STAMPER_FIELDS.get(sobjType).add(record.SObject_Field__c);
                }
            }
            return STAMPER_FIELDS;
        }
        set;
    }

    private List<SObject_Stamper__mdt> getStampers(SObject sobj) {
        return getStampers(sobj.getSObjectType());
    }

    private List<SObject_Stamper__mdt> getStampers(SObjectType sobjType) {
        List<SObject_Stamper__mdt> records = STAMPER_MAP.get(sobjType);
        return STAMPER_MAP.containsKey(sobjType) ? STAMPER_MAP.get(sobjType) : new List<SObject_Stamper__mdt>();
    }

    private SObjectValue getSObjectValue(SObject sobj, String formula) {
        if(String.isBlank(formula)) {  throw new TypeException('String formula should not be null'); }
        if(sobj == null)            {  throw new TypeException('SObject sobj should not be null'); }

        List<String> sections = formula.split('\\.');
        if(sections.size() > 3) { throw new TypeException('sections too large for SOQL query'); }

        if(sections.size() == 0) {
            SObjectStamperConstants.DataType retType = getDataType(sobj, formula);
            return new SObjectValue(sobj, formula, retType);
        }

        SObject retObj = sobj;
        String field = null;
        // Travel down the list of sobjects, until you reach the last section
        for(Integer i = 0; i < sections.size()-1; i++) {
            if(retObj == null) { break; }

            field = sections.get(i);
            retObj = retObj.getSObject(field);
        }

        SObjectStamperConstants.DataType retType = getDataType(retObj, field);
        String finalField = sections.get(sections.size()-1);

        return new SObjectValue(retObj, finalField, retType);
    }

    public static SObjectStamper newInstance() {
        return new SObjectStamper();
    }

    public SObjectStamper execute(List<SObject> records) {
        // Early exit condition
        if(records == null || records.isEmpty()) return this;

        Set<Id> recordIds = new Set<Id>();
        Set<SObjectType> types = new Set<SObjectType>();
        Set<String> fields = new Set<String>();
        for(SObject record : records) {
            recordIds.add((Id) record.get('Id'));
            types.add(record.getSObjectType());
        }
        if(types.size() > 1) { throw new TypeException('Too many types of sobjects'); }
        types = null;

        SObjectType sobjType = records[0].getSObjectType();

        // TODO: use a selector framework
        Set<String> theFields = STAMPER_FIELDS.get(sobjType);
        theFields.add('Id');
        Map<Id, SObject> requeriedRecords = new Map<Id, SObject>(Database.query('SELECT '+String.join(new List<String>(theFields), ',')+' FROM '+String.valueOf(sobjType)+' WHERE Id IN :recordIds'));

        // Perform the dynamic magic
        for(SObject record : records) {
            Id recordId = (Id) record.get('Id');
            SObject requeriedRecord = requeriedRecords.get(recordId);

            for(SObject_Stamper__mdt stamper : getStampers(sobjType)) {
                SObjectValue result = getSObjectValue(requeriedRecord, stamper.Formula__c);
                record.put(stamper.SObject_Field__c, result.value);
            }
        }

        return this;
    }

    private static SObjectStamperConstants.DataType getDataType(SObject sobj, String field) {
        Schema.DisplayType dt = sobj.getSObjectType().getDescribe().fields.getMap().get(field).getDescribe().getType();
        return SObjectStamperConstants.TYPE_MAPPING.get(dt);
    }

    private SObjectStamper() {}

}
