public with sharing virtual class MMR_ComponentControllerBase
{
    public String key{ get;
    set{
      if(value != null){
         Key  = value;
         if(pageController != null)
            pageController.setComponentControllerMap(Key, this);
      }
    }
  }
  
  public MMR_PageControllerBase pageController { get; 
    set {
      if (value != null) {
    pageController = value;
    pageController.setComponentController(this);
      }
    }
  }  
}