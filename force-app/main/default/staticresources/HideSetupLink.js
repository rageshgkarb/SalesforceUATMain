// ======================================================================================================================
// SUGGESTED CONTENT OF A SCRIPT TO HIDE THE "SETUP" LINK IN STANDARD SALESFORCE PAGES,
// WHERE THE SETUP | CUSTOMIZE | USER INTERFACE | Enable Improved Setup User Interface OPTION
// HAS BEEN CHECKED AND SETUP THUS APPEARS AS A STAND-ALONE LINK, RATHER THAN AS A PICK
// LIST ITEM BENEATH THE USER'S NAME.

// THIS SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND AND IS NOT A SUPPORTED COMPONENT 
// OF ANY IMPROVED APPS PRODUCT. THE RECIPIENT MUST SATISFY THEMSELVES OF THE SUITABILITY AND 
// APPLICABILITY OF THIS CODE PRIOR TO USE AND MAY MODIFY ITS CONTENTS AT WILL.

// TO USE THIS SCRIPT:

//	- Choose a name that will be used for a sidebar links component (its label text)
//	- Enter this name as the value of the "ComponentLabel" variable in the script below
// 	- Upload the amended script as a static resource
//	- Create a custom link (Setup | Customise | Home | Custom Links) pointing to the resource as a required script:
//		- Behaviour = execute Javascript
//		- Onclick Javascript body text = "{!REQUIRESCRIPT("[full URL of the uploaded script resource]")}"
//	- Create a narrow / sidebar links type home page component featuring the custom link
//	- Include the sidebar links component on the home page layout of the required profile(s)

// ======================================================================================================================

// Label of the sidebar component we wish to hide:
var ComponentLabel = "Hide Setup Link";

// For looping
var i;

// For locating sidebar component parts
var labels;


// Hide the setup link
document.getElementById('setupLink').style.display = 'none';

// Hide the desired links component: To do this, get all sidebar component headings...
var x = document.getElementsByClassName("sidebarModuleHeader");

// ... then loop through these looking for one with the desired label
for (i = 0; i < x.length; i++) {
	labels = x[i].getElementsByTagName('h2');

	if (labels.length > 0) {
		if (labels[0].innerText == ComponentLabel) {
			x[i].parentNode.style.display = 'none';
			break;
		}
	}
}