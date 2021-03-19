global virtual class Response {
    @AuraEnabled global Boolean success;
    @AuraEnabled global String message;
    @AuraEnabled global Map<String, Object> values;

    global Response() {
        this(false, 'Empty Response');
    }

    global Response(Boolean success, String message) {
        this(success, message, new Map<String, Object>());
    }

    global Response(Boolean success, String message, Map<String, Object> values) {
        this.success = success;
        this.message = message;
        this.values = values;
    }

}