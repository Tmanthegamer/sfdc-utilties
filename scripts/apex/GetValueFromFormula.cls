public static Object getValueFromFormula(SObject sobj, String formula) {
    if(String.isBlank(formula)) {  throw new TypeException('String formula should not be null'); }
    if(sobj == null)            {  throw new TypeException('SObject sobj should not be null'); }

    List<String> sections = formula.split('\\.');
    if(sections.size() > 3) { throw new TypeException('sections too large for SOQL query'); }

    if(sections.size() == 0) {
        return sobj.get(formula);
    }

    SObject retObj = sobj;
    // Travel down the list of sobjects, until you reach the last section
    for(Integer i = 0; i < sections.size()-1; i++) {
        String field = sections.get(i);
        retObj = retObj.getSObject(field);
    }

    return retObj.get(sections.get(sections.size()-1));
}



Account acc = new Account(
    Primary_Contact__r = new Contact(
        FirstName = 'Tommy',
        LastName = 'Boi',
        Account = new Account(
            Name = 'It ya boi'
        )
    ),
    Name = 'tacos'
);
String formula = 'Name';
Object value = getValueFromFormula(acc, formula);
System.debug(value);