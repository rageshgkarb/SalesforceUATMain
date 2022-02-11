$(document).ready(function() {
	/* Summary Tooltips */
	
	var tipconfig = {
		interval: 400,    
     		over: showTipItem,// function = onMouseOver callback (REQUIRED)    
     		timeout: 500, // number = milliseconds delay before onMouseOut    
     		out: hideTipItem// function = onMouseOut callback (REQUIRED)    
	};

	$(".ToolTip").hoverIntent(tipconfig);
	function showTipItem(){ $(this).next(".ToolTipItem").show()};
	function hideTipItem(){ $(this).next(".ToolTipItem").hide()};
		

	var tooltipconfig = {    
     		over: showTip,// function = onMouseOver callback (REQUIRED)    
     		timeout: 1000, // number = milliseconds delay before onMouseOut    
     		out: hideTip// function = onMouseOut callback (REQUIRED)    
	};

	$(".ToolTipItem").hover(showTip,hideTip);
	function showTip(){ $(this).show()};
	function hideTip(){ $(this).hide()};

});
                              
