public with sharing virtual class MMR_PageControllerBase extends MMRBaseEventController{
    
    
  private MMR_ComponentControllerBase myComponentController;
  private Map<String, MMR_ComponentControllerBase>componentControllerMap; //new
    
  public virtual MMR_ComponentControllerBase getMyComponentController() {
    return myComponentController;
  }

  //new getter for the hashmap
  public virtual Map<String, MMR_ComponentControllerBase> getComponentControllerMap(){
    return componentControllerMap;
  }
  //new method for putting value in the hashmap
  public virtual void setComponentControllerMap(String key, MMR_ComponentControllerBase compController){
    if(componentControllerMap == null)
      componentControllerMap = new Map<String, MMR_ComponentControllerBase>();
    componentControllerMap.put(key,compController); 
  }

  public virtual void setComponentController(MMR_ComponentControllerBase compController) {
    myComponentController = compController;
  }
    
  public MMR_PageControllerBase getThis() {
    return this;
  }
    
}