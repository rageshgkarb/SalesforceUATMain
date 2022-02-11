/* ------------------------------------------------------------------------------- */
/* C0075 Offer Letter Expiration Schedule                                          */
/* ------------------------------------------------------------------------------- */


global class HPPOfferLetterExpirySchedule implements Schedulable
{
      global void execute (SchedulableContext SC)
      {
          HPPOfferLetterExpiry expire = new HPPOfferLetterExpiry();
          expire.Expire();
      }
}