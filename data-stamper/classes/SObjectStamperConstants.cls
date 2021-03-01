public class SObjectStamperConstants {
    public static final Map<Schema.DisplayType, DataType> TYPE_MAPPING = new Map<Schema.DisplayType, DataType>{
        Schema.DisplayType.ADDRESS                    => DataType.M_UNSUPPORTED,
        Schema.DisplayType.ANYTYPE                    => DataType.M_UNSUPPORTED,
        Schema.DisplayType.BASE64                     => DataType.M_UNSUPPORTED,
        Schema.DisplayType.BOOLEAN                    => DataType.M_CHECKBOX,
        Schema.DisplayType.COMBOBOX                   => DataType.M_UNSUPPORTED,
        Schema.DisplayType.CURRENCY                   => DataType.M_CURRENCY,
        Schema.DisplayType.DATACATEGORYGROUPREFERENCE => DataType.M_UNSUPPORTED,
        Schema.DisplayType.DATE                       => DataType.M_DATE,
        Schema.DisplayType.DATETIME                   => DataType.M_DATETIME,
        Schema.DisplayType.DOUBLE                     => DataType.M_NUMBER,
        Schema.DisplayType.EMAIL                      => DataType.M_TEXT,
        Schema.DisplayType.ENCRYPTEDSTRING            => DataType.M_UNSUPPORTED,
        Schema.DisplayType.ID                         => DataType.M_ID,
        Schema.DisplayType.INTEGER                    => DataType.M_ID,
        Schema.DisplayType.LONG                       => DataType.M_NUMBER,
        Schema.DisplayType.MULTIPICKLIST              => DataType.M_UNSUPPORTED,
        Schema.DisplayType.PERCENT                    => DataType.M_NUMBER,
        Schema.DisplayType.PHONE                      => DataType.M_TEXT,
        Schema.DisplayType.PICKLIST                   => DataType.M_TEXT,
        Schema.DisplayType.REFERENCE                  => DataType.M_ID,
        Schema.DisplayType.STRING                     => DataType.M_TEXT,
        Schema.DisplayType.TEXTAREA                   => DataType.M_TEXT,
        Schema.DisplayType.TIME                       => DataType.M_UNSUPPORTED,
        Schema.DisplayType.URL                        => DataType.M_TEXT
    };

    public enum DataType {
        M_CHECKBOX,
        M_CURRENCY,
        M_DATE,
        M_DATETIME,
        M_NUMBER,
        M_PERCENT,
        M_TEXT,
        M_ID,
        M_UNSUPPORTED
    }

}
