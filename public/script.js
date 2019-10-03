function validateForm(){
	var x = document.forms["myForm"]["username"].value;
	if(x==null || x==""){
		alert("Name must be filled out");
		return false;
	}
	var y = document.forms["myForm"]["password"].value;
	if(y==null || y==""){
		alert("Name must be filled out");
		return false;
	}
}
