public with sharing class PublicHolidaysController {


    public Class PublicHolidays{
        @AuraEnabled public String description, primaryType;
        @AuraEnabled public Date cDate;
    }

    @AuraEnabled
    public static List<PublicHolidays> getPublicHolidays(String targetYear){
        Calendarific__mdt cldMtd = [Select URL__c,API_Key__c from Calendarific__mdt Where Label = 'Credentials' Limit 1];
        String apiUrl = cldMtd.URL__c + '?api_key=' + cldMtd.API_Key__c + '&country=ZA&year='+targetYear;
        HttpResponse res = sendApiCall(apiUrl, 'GET', null);

        List<PublicHolidays> lstPubHolidays = new List<PublicHolidays>();
        if(res.getStatusCode() == 200){
            System.debug('res: ' + JSON.deserializeUntyped(res.getBody()));
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object> a = (Map<String, Object>) m.get('response');
            List<Object> b = (List<Object>)a.get('holidays');

            for(Object o:b){
                PublicHolidays pHolidays = new PublicHolidays();
                pHolidays.description = String.valueOf(o).split('description=')[1].split(', locations')[0];
                pHolidays.cDate = Date.valueOf(String.valueOf(o).split('iso=')[1].split('}')[0]);
                pHolidays.primaryType = String.valueOf(o).split('primary_type=')[1].split(',')[0];
                lstPubHolidays.add(pHolidays);
            }
        }
        return lstPubHolidays;
    }

    @AuraEnabled
    public static void upsertIdInformation(String saId){
        List<ID_Information__c> lstIdInfo = [Select Id, Search_Count__c from  ID_Information__c where name =: saId];
        if(lstIdInfo != null && lstIdInfo.size() > 0){
            lstIdInfo[0].Search_Count__c = lstIdInfo[0].Search_Count__c + 1;
            update lstIdInfo;
        }else{
            ID_Information__c idInfo = new ID_Information__c();
            idInfo.name = saId;
            idInfo.Gender__c = Integer.valueOf(saId.subString(6, 10)) > 4999 ? 'Male' : 'Female';
            idInfo.Date_of_Birth__c = Date.newInstance(Integer.ValueOf('19'+saId.subString(0, 2)), Integer.ValueOf(saId.subString(2, 4)), Integer.ValueOf(saId.subString(4, 6)));
            idInfo.Search_Count__c = 1;
            idInfo.SA_Citizen__c = saId.subString(10, 11) == '0' ? true : false;
            insert idInfo;
        }
    }

    public static HttpResponse sendApiCall(String endPointURL,String method, String body){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setEndPoint(endPointURL);
        System.debug(endPointURL);
        if(body != null)
            req.setBody(body);
        req.setMethod(method);
        Http http = new Http();
        res = http.send(req);
       
        System.debug('Response Status : '+res.getStatus());
        System.debug('Response Status Code : '+res.getStatusCode());
        System.debug('Response Body : '+res.getBody());
        return res;
    }
}