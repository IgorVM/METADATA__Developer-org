public class StringArrayTest {
    public static List<String> generateStringArray(Integer countOfTest){
        List<String> testStrings = new List<String>();
        for(Integer i = 0; i < countOfTest; i++){
            testStrings.add('Test ' + i);
        }
        return testStrings;
    }
}