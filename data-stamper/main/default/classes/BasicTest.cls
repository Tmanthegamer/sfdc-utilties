@isTest
public class BasicTest {
    @isTest
    private static void alwaysTrue() {
        System.assert(true, 'This is a smoke test');
    }
}
