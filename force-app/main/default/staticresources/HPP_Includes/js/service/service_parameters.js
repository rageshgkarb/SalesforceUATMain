hppApp.service('serviceParameters', ['$q', '$rootScope', function ($q, $rootScope) {

	function _tellerParams()
	{
		this.Name = '';
		this.ImageURL = ''
		this.Branch = '';
		this.BranchNumber = '';
	}
	this.TellerParams = new _tellerParams();

	function _mandateParams()
	{
		this.Mandate_AccountNum = '';
		this.Mandate_AccountId = '';
		this.Mandate_SelecetdId = '';
	}
	this.MandateParams = new _mandateParams();

	function _loadParams()
	{
		this.ShowRequestCount = 0;
	};
	this.LoadParams = new _loadParams();

	function _customerParams()
	{
		this.SelectedId = null;
		this.SelectedEBSId = null;

		this.Initialise = function()
		{
			this.SelectedId = null;
			this.SelectedEBSId = null;
		}
	};
	this.CustomerParams = new _customerParams();

	function _balanceTillParams()
	{
		this.TillId = '';
		this.PreviousState = '';
		this.SuccessFlag = false;
		this.SuccessState = '';
	}
	this.BalanceTillParams = new _balanceTillParams();

	function _openTillParams()
	{
		this.TillId = '';
		this.PreviousState = '';
		this.SuccessFlag = false;
		this.SuccessState = false;
	}
	this.OpenTillParams = new _openTillParams();

	function _closeTillParams()
	{
		this.TillId = '';
		this.PreviousState = '';
		this.SuccessFlag = false;
		this.SuccessState = false;
		this.TillAuthorisors = null;
	}
	this.CloseTillParams = new _closeTillParams();

	function _transactionParams()
	{
		this.FunctionId = null;
		this.Account = null;
	};
	this.TransactionParams = new _transactionParams();

	function _applicationParams()
	{
		this.ResourceDenominationPath = '';
		this.ResourcePath = '';
		this.ModalType = '';
	}
	this.ApplicationParams = new _applicationParams();

	function _customerSearchParams()
	{
		this.SearchCriteria = '';
		this.RecentCustomers = [];

		this.GetRecentCustomers = function()
		{
			return this.RecentCustomers;
		}

		this.AddRecentCustomer = function(customer)
		{
			var index = this.RecentCustomers.indexOf(customer);
			if(index == -1)
			{
				if (this.RecentCustomers.length == 5) 
            	{
                	this.RecentCustomers.splice(4, 1);
            	}

				this.RecentCustomers.splice(0, 0, customer);
			}
			else
			{
				this.RecentCustomers.splice(index, 1);
				this.RecentCustomers.splice(0, 0, customer);
				//this.RecentCustomers.push(customer);
			}
		}

		this.ClearRecentCustomers = function()
		{
			this.RecentCustomers = [];
		}
	} 
	this.CustomerSearchParams = new _customerSearchParams();

	function _activityParams()
	{
		this.SelectedActivityReference = '';
		this.SelectedActvityType = '';
	}
	this.ActivityParams = new _activityParams();

	function _stateParams()
	{
		this.Params = null;
	}
	this.StateParams = new _stateParams();

	this.Clear_StateParams = function ()
	{
		this.StateParams.Params = null;
	}

	function _preCaseSelection()
	{
		this.pageData;
		this.AuthorisorNo;
		this.CaseId;
		this.CaseNo;
	}
	this.PreCaseSelection = new _preCaseSelection;

}]);