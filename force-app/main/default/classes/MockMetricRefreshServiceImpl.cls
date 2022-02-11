@isTest
global class MockMetricRefreshServiceImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        //Fake Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"isMockResponse":"true"}');
        res.setStatusCode(200);
        return res;
    }
}