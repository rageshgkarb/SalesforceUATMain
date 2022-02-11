
tellerApp.filter('filter_accountNumber', function () {
	return function(accountNumber) {
        if(typeof accountNumber == 'undefined' || accountNumber == null)
            return accountNumber;
            
        var value = accountNumber.split('-').join('');
        if(typeof value != 'undefined' &&  value.length >= 13)
        {
		  return value.slice(0,4) + '-' + value.slice(4,10) + '-' + value.slice(10,13);	
        }
        else
        {
            return value;
        }
	};
});

tellerApp.filter('newlines', function () {
    return function(text) {
        return text.replace(/\n/g, '<br/>');
    }
})
.filter('noHTML', function () {
    return function(text) {
        return text
                .replace(/&/g, '&amp;')
                .replace(/>/g, '&gt;')
                .replace(/</g, '&lt;');
    }
});

tellerApp.filter('filter_currencytosymbol', function () {
    return function(currency) {
        switch(currency)
        {
            case 'USD':
                return '$';
            case 'GBP':
                return '£';
			case 'EUR': // C0677 start
				return '€';
			case 'QAR':
				return 'ر.ق'; // C0677 end
            default:
                return currency;
        }
    };
});

tellerApp.filter('filter_removedoublebackslash', function() {
    return function(source) {
        do {
            source = source.replace("//", "/");
        } while (source.indexOf("//") !== -1);
        return source;
    };
});

tellerApp.filter('filter_setdecimal', function () {
    return function (input, places) {
        if (isNaN(input)) return input;
        // If we want 1 decimal place, we want to mult/div by 10
        // If we want 2 decimal places, we want to mult/div by 100, etc
        // So use the following to create that factor
        var factor = "1" + Array(+(places > 0 && places + 1)).join("0");
        return Math.round(input * factor) / factor;
    };
});