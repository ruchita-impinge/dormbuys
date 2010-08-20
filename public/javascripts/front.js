$(document).ready(function(){
	setupHomePageCatBannerNav();
	$("a.lightwindow").colorbox();
	$('a#learn_more_secure, a.learn_more_dorm_ship, a.learn_more_gift').colorbox({width:'700px'});
	$('a#what_is_vcode').colorbox({innerWidth:'311px', innerHeight:'255px'});
	swapPopupImage();
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



function swapPopupImage()
{	
	$(".quick-popup").each(function(){
		
		var popup = $(this)
		var img = popup.find('.popup-main-img')
		var oSource = img.attr("src");
		
		popup.find('a.additional_image').each(function(){
			
			var imgLink = $(this);
			
			imgLink.mouseover(function(){
				img.attr("src", imgLink.attr("rel"));
			});//end mouseover
			
			imgLink.mouseout(function(){
				img.attr("src", oSource);
			});//end mouseout
			
		});//end each link
		
	});//end each

}//end function swapPopupImage