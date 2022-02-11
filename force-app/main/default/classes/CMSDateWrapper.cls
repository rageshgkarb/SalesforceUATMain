public with sharing class CMSDateWrapper {
  	public date theDate {
  		get{
  			if(theDate == null){
  				theDate = date.today();
  			}
  			return theDate;
  		}
  		set;
  	}
}