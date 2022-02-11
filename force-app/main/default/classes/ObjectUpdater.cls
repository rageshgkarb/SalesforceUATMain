public class ObjectUpdater {
	public List<SObject> objectsToUpdate {get; set;}
	
	public ObjectUpdater(){
		objectsToUpdate = new List<SObject>();
	}
	
	public void updateObjects(){
		if (objectsToUpdate.size() > 0){
			try {
				Database.Upsertresult[] results = Database.upsert(objectsToUpdate, true);
				for (Database.Upsertresult res : results){
					System.debug('*** -- Result for ID: ' + res.getId() + ' = ' + res.isSuccess() + '-- ***');
				}
				
			}catch (Exception e){
				System.debug('*** -- Error in ObjectUpdater.updateObjects -- ***');
			}
		}
	}
}