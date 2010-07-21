var countdown_seconds;
var timer;
var timer2;
var should_reload = false;
var original_img_url;
var original_link_text;

$(document).ready(function(){
	
	//setup the countdown timer
	countdown_seconds 	 = Number($("#countdown_seconds").text());
	setTimeLeft();
	
	//setup the sellout meter
	setupSelloutMeter();
	
	//setup the image rollovers
	setupImageRollovers();
	$("a.lightwindow").colorbox();
	
	//email form behavior
	$("#email").focus(function(){
		$(this).val("");
	});

	
	//setup faq link
	$("#ddd_info_link, #ddd_info_link2").colorbox({width: "750px", height: "615px", inline:true, href:"#ddd_info"});
	
});//end ready


function setTimeLeft()
{
	if(countdown_seconds > 0)
	{
		var h = Math.floor(countdown_seconds / 60 / 60);
		var m = Math.floor((countdown_seconds - (3600 * h)) / 60);
		var s = Math.floor(countdown_seconds - (3600 * h) - (60 * m));
	
		var text = leadZero(h) + ":" + leadZero(m) + ":" + leadZero(s);
		$("#countdown_clock").text(text);
		countdown_seconds = countdown_seconds - 1;
		timer = setTimeout("setTimeLeft();", 1000);
		
		should_reload = true;
		
	} else {
		
		$("#countdown_clock").text("00:00:00");
		
		clearTimeout(timer);
		
		//reload the page after 5 seconds
		if(should_reload == true)
		{
			timer2 = setTimeout("window.location.href=window.location.href;", 5000);
		}
		
		if($("#soldout-banner").length == 0)
		{
			$("#wrapper").prepend('<div id="soldout-banner"></div>');
		}
		
	}//end if-else
	
}//end function setTimeLeft



function leadZero(num)
{
	if(num >= 10)
		return num.toString();
	else
		return "0" + num.toString();
	
}//end leadZero



function setupSelloutMeter()
{
	var percent_sold = Number($("#percent_sold").text());
	var all_sold_width = 223;
	var new_width;
	
	if(percent_sold == 100){
		
		new_width = 246;
		$(".intro .left-to-buy .slider .pointer").css("left", "93%");
		
	} else if(percent_sold < 100) {
		
		new_width =  Math.round(all_sold_width * (percent_sold / 100));
		
	} else {
		
		new_width = 0;
	}
	
	$(".intro .left-to-buy .slider .top-slide").css("width", new_width.toString() + "px");
	
}//end function setupSelloutMeter



function setupImageRollovers()
{
	$img = $("#img_enlarge_image");
	original_img_url = $img.attr("src");
	
	$lnk = $("#link_enlarge_image");
	original_link_text = $lnk.text();
	
	$("a.additional_image").mouseover(function(){
		$img.attr("src", $(this).attr("rel"));
		if( $(this).attr("title") != "")
		{
			$lnk.text($(this).attr("title"));
		}
	});
	
	$("a.additional_image").mouseout(function(){
		$img.attr("src", original_img_url);
		$lnk.text(original_link_text);
	});
	
}//end setupImageRollovers



function validateSelection()
{
	var pass = true;
	
	$("select").each(function(){

		if( $(this).val() == "" )
		{
			pass = false;
		}

	});
	
	if(pass == false)
	{
		alert("ERROR:\nPlease select all options");
		
	} else {

		$("#cart_form").submit();
		
	}

	
}//end validateSelection