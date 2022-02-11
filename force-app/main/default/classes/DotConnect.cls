/**
 * Created by lbrindle on 09/10/2018.
 */

public with sharing class DotConnect {

    public class DotConnectException extends Exception{
        public String errorCode {get;set;}
        public String errorMessage {get;set;}

        public DotConnectException(String errorCode, String errorMessage){
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }
    }
}