caaApp.controller('controllerProductDetails', ['$scope',
        function ($scope) 
        {
            $scope.Product = {ShowTransfer: true, ShowRegularPayment: true, Name: 'Some Product'};
            
            
            
            $scope.ShowCompleteButton = function () {
                var product = $scope.Product;
                
                if(!product)
                    return false;
                    
                    
                if(product.ShowTransfer)
                {
                    if(!product.WhatToDoWithProfit) return false;
                
                    if(product.WhatToDoWithProfit == 'transfer' &&  !product.TransferToType  )    
                        return false;
                    
                    //external transfer needs to have the account and sortcode 
                    if(product.WhatToDoWithProfit == 'transfer' &&  product.TransferToType == 'external' &&
                         (!product.TransferToAccount || !product.TransferToSortCode)  )    
                        return false;   
                }    
                
                if(product.ShowRegularPayment)
                {
                    if(!product.HasRegularPayment) return false;
                
                    if(product.HasRegularPayment == 'yes' && (!product.RegularPaymentAmount || !product.RegularPaymentFrequency 
                        || !product.RegularPaymentDate || !product.RegularPaymentDay || !product.RegularPaymentMonth || !product.RegularPaymentYear || !product.HasFinalPayment) )
                        return false;
                        
                    if(product.HasFinalPayment == true &&  (!product.FinalPaymentBank || !product.FinalPaymentAccountNumber || !product.FinalPaymentSortCode))   
                        return false;   
                }
                    
                 
                    
                    
                
                
                
                
                return true;    
            };
        }
    ]);