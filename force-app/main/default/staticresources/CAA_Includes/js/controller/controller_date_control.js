caaApp.controller('DateController', ['$scope',
        function($scope)
        {
            $scope.init = function (scop,field, required,years) {
                $scope.sc = scop;
                $scope.field = field;                                
		$scope.required = required;
                $scope.day= $scope.sc[$scope.field].Day;
                $scope.month = $scope.sc[$scope.field].Month ;
                $scope.year= $scope.sc[$scope.field].Year;   


		$scope.days = [];
		$scope.days.push({"key":"", "value":"Please select"});
		for(var i = 1 ; i <= 31; i++)
			$scope.days.push({"key":i.toString(), "value":i.toString()});


		$scope.daysSM=[];
		$scope.daysSM.push({"key":"", "value":"DD"});
		for(var i = 1 ; i <= 31; i++)
			$scope.daysSM.push({"key":i.toString(), "value":i.toString()});


		$scope.months = [
					{"key":"", "value":"Please select"},
					{"key":"1", "value":"January"},
					{"key":"2", "value":"February"},
					{"key":"3", "value":"March"},
					{"key":"4", "value":"April"},
					{"key":"5", "value":"May"},
					{"key":"6", "value":"June"},
					{"key":"7", "value":"July"},
					{"key":"8", "value":"August"},
					{"key":"9", "value":"September"},
					{"key":"10", "value":"October"},
					{"key":"11", "value":"November"},
					{"key":"12", "value":"December"}					
				];
		$scope.monthsSM = [
					{"key":"", "value":"MM"},
					{"key":"1", "value":"Jan"},
					{"key":"2", "value":"Feb"},
					{"key":"3", "value":"Mar"},
					{"key":"4", "value":"Apr"},
					{"key":"5", "value":"May"},
					{"key":"6", "value":"Jun"},
					{"key":"7", "value":"Jul"},
					{"key":"8", "value":"Aug"},
					{"key":"9", "value":"Sep"},
					{"key":"10", "value":"Oct"},
					{"key":"11", "value":"Nov"},
					{"key":"12", "value":"Dec"}					
				];

		$scope.years = [];
		$scope.years.push({"key":"", "value":"Please select"});
		
		
		var currentYear = new Date().getFullYear();		
		
		if(years > 0)
		{
			//PYFIX
			years++;
			//PYFIX : 03-01-2017: Added -1 to show previous year
			for(var i = currentYear-1; i < currentYear + years; i++)
				$scope.years.push({"key":i.toString(), "value":i.toString()});
			
		}
		else
		{
			for(var i = currentYear; i > currentYear + years; i--)
				$scope.years.push({"key":i.toString(), "value":i.toString()});
		}

		//console.log($scope.years);
		
		$scope.yearsSM = [];
		$scope.yearsSM.push({"key":"", "value":"YY"});
		var currentYear = new Date().getFullYear();		
		
		if(years > 0)
		{
			for(var i = currentYear - 1; i < currentYear + years; i++)
				$scope.yearsSM.push({"key":i.toString(), "value":i.toString()});
			
		}
		else
		{
			for(var i = currentYear; i > currentYear + years; i--)
				$scope.yearsSM.push({"key":i.toString(), "value":i.toString()});
		}

             
            };              
            
            $scope.IsInValid = function(){
            
                if(!$scope.year || !$scope.month || !$scope.day || $scope.day == 0 || $scope.month == 0 || $scope.year == 0)
			return false;



		
                   
                var m = parseInt($scope.month, 10);
                var d = parseInt($scope.day, 10);
                var y = parseInt($scope.year, 10);    
                    
                var date = new Date(y,m-1,d);
                if (date.getFullYear() == y && date.getMonth() + 1 == m && date.getDate() == d) {
                    return false;
                } else {
                    return true;
                }      
            }
        
        
            $scope.$watch('day',function(){

		var f = $scope.sc[$scope.field];
		var ff = $scope.sc[$scope.field].Day;

               $scope.sc[$scope.field].Day = $scope.day;              
            });
            
            $scope.$watch('month',function(){
               $scope.sc[$scope.field].Month= $scope.month;
            });
            
            $scope.$watch('year',function(){
                $scope.sc[$scope.field].Year = $scope.year;               
            });
           
            
        }    
    
      ]);