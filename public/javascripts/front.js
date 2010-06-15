$(document).ready(function(){
	setupHomePageCatBannerNav();
	$("a.lightwindow").colorbox();
	$('a#learn_more_secure, a.learn_more_dorm_ship, a.learn_more_gift').colorbox({width:'700px'});
	$('a#what_is_vcode').colorbox({innerWidth:'301px', innerHeight:'245px'});
});//end ready

//function to mark items that are JS removed for real delete
function mark_for_destroy(element, css_class)
{
	$(element).next().next().val(1);
	$(element).parents(css_class).hide();
}


function mark_gift_name_for_destroy(element, css_class)
{
	$(element).parent().next().next().val(1);
	$(element).parents(css_class).hide();
}

function setupHomePageCatBannerNav()
{

	$("#home_banner_cat_nav a").click(function(){
		var tab_id = $(this).attr("href");
		$(tab_id + " .list").css("margin-top", (($(tab_id).height() - $(tab_id + " .list").height()) / 2) + "px");
	});
	
}//end function