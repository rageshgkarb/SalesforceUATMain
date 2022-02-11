tellerApp.service('serviceApplication', ['$q', '$rootScope', '$window', '$state', 'serviceParameters', 'serviceMessageBroker', 
    function ($q, $rootScope, $window, $state, serviceParameters, serviceMessageBroker) {

    this.ShowRequestCount = 0;
            
	this.LoadShow = function(message){
		this.ShowRequestCount++;
        serviceMessageBroker.LoadShow(message);
    }

    this.LoadHide = function(forceHide){
        if(forceHide)
            this.ShowRequestCount = 0;
    	if(this.ShowRequestCount > 0)
    		this.ShowRequestCount--;
    	if(this.ShowRequestCount == 0)
        {
            serviceMessageBroker.LoadHide();
            serviceMessageBroker.LoadHideComplete();
        }
    }

    this.LoadOpen = function()
    {
        if(this.ShowRequestCount > 0)
            return true;
        return false;
    }

    this.ModalShow = function(title, modalType){
        serviceMessageBroker.ModalShow(title, modalType);      
    }

    this.ModalHide = function(){
        serviceMessageBroker.ModalHide();
    }

    this.PrintHTML = function(htmlString)
    {
        if(htmlString)
        {
            var popupWindow = $window.open('', '_blank', 'width=800, height=600, directories=no, location=no, status=no');
            popupWindow.document.childNodes[0].innerHTML = '<html><head><link rel="stylesheet" type="text/css" href="test.css" /></head><body>' + htmlString + '</html>';
            popupWindow.print();
            popupWindow.document.close();
            popupWindow.close();
        }
        else
        {
            alert('Error: Print template is corrupt');
        }
    }

    this.ParseHTML = function(htmlString)
    {
        return jQuery.parseHTML(htmlString);
    }

    this.GetParameterByNameFromURL = function(name) 
    {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }

    this.CreateWebLog = function(objectId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.CreateWebLog(objectId, function (result, event) {            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.ParseHTMLString = function(htmlString)
    {
        var result = jQuery.parseHTML(htmlString); 
        if(result != null) 
            return result[0].data;
        return htmlString;
    }

    this.ParseHTMLList = function(list)
    {
        if(list != null && list.length > 0)
        {
            var toParse = Enumerable.From(list);
            toParse.ForEach(function(item) 
                                { 
                                    var result = jQuery.parseHTML(item); 
                                    if(result != null) 
                                        item = result[0].data;
                                }
                            );
        }
    }

    this.ParseHTMLList = function(list, paramlist)
    {
        if(list != null && list.length > 0)
        {
            var toParse = Enumerable.From(list);
            toParse.ForEach(function(item) 
                                { 
                                    var params = Enumerable.From(paramlist);
                                    params.ForEach(function(paramName)
                                        {
                                            var result = jQuery.parseHTML(item[paramName]); 
                                            if(result != null) 
                                                item[paramName] = result[0].data;
                                        }); 
                                }
                            );
        }
    }

}]);	