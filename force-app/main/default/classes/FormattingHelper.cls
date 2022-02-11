global class FormattingHelper{
 
	global static String CurrencySymbol(String text)
	{
		String returnSymbol = '';

		if (text.contains('EUR'))
		{
			returnSymbol = '€';
		}
		else if ((text.contains('GBP')) || (text.contains('Pound Sterling')))
		{
			returnSymbol = '£';
		}
		else if ((text.contains('USD')) || (text.contains('US Dollar')))
		{
			returnSymbol = '$';
		}
		else if (text.contains('Saudi Riyal'))
		{
			returnSymbol = '﷼';
		}
        else if ((text.contains('QAR')) || (text.contains('Qatar Riyal')))
        {
            returnSymbol = 'ريال';
        }

		return returnSymbol;
	}

	global static String FormattedCurrency(String CCY, Decimal Amount)
	{
		system.debug('FormattingHelper.FormattedCurrency Entry');
		system.debug('CCY: ' + CCY);
		system.debug('Amount: ' + Amount);
		String i = Amount.toPlainString();

    	String response = CurrencySymbol(CCY) + (Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
    	response = response.substring(0,response.length()-1);

    	system.debug('response: ' + response);
    	return response;
	}

}