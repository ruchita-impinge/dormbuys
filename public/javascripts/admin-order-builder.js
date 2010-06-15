jQuery(document).ready(function(){
	initAdminOrderBuilder();
});

function initAdminOrderBuilder()
{
	jQuery("#shipping_fieldset").hide();
	jQuery("#order_user_profile_type_id").change(shippingAddressPicker);
	jQuery("#btn_add_coupon").click(addCoupon);
	jQuery("#btn_add_gift_card").click(addGiftCard);
	jQuery("#btn_calc_shipping").click(calculateShipping);
	jQuery("#btn_submit_orders").click(submitOrder);
	
	jQuery("#order_subtotal, #order_tax, #order_total_coupon, #order_total_giftcards, #order_total_discounts").blur(updateOrderTotals);
	jQuery("#order_shipping").blur(function(){
		skip_shipping_calc = true;
		updateOrderTotals();
	});
	
}//end function


var order_submitting = false;
function submitOrder(e)
{
	e.preventDefault();
	
	if(order_submitting == true) return;
	order_submitting = true;
	
	//submit the order builder
	jQuery("#btn_submit_orders")
	    .removeClass("positive")
	    .html("<span>Please wait...</span>")
	    .next(".button").hide();
	
	jQuery.ajax({
	   type: "POST",
	   dataType: 'script',
	   url: "/admin/orders/save_orders",
	   data: jQuery("form").serialize()
	 });
	
}//end function submitOrder



function reEnableForm()
{
	order_submitting = false;
	
	jQuery("#btn_submit_orders")
	    .addClass("positive")
	    .html("<span>Save</span>")
	    .next(".button").show();
	
}//end function



function updateProductTotal()
{
	jQuery("input.product_quantity").each(function(){
		
		jQuery(this).unbind("blur");
		var inpt = jQuery(this);
		inpt.blur(function(){
			var qty = jQuery(this).val();
			var unit_price = jQuery(this).parents(".order_item").contents().find(".product_unit_price").val();
			var total = unit_price * qty;
			
			//FORMAT THIS SET
			jQuery(this).parents(".order_item").contents().find(".product_total_price").val(formatCurrency(total));
			
			updateOrderTotals();
		
		});//end blur
		
	});//end each
	
}//end function


var skip_shipping_calc = false;
function updateOrderTotals()
{
	updateSubTotal();
	calculateTax();
	updateCoupons();
	
	if(skip_shipping_calc)
	{
		skip_shipping_calc = false;
		
	} else {

		calculateShipping();
		
	}

	updateGiftCards();
	updateGrandTotal();
	
}//end function updateOrderTotals



function updateGrandTotal()
{
	var totals = Number(jQuery("#order_subtotal").val()) + Number(jQuery("#order_tax").val()) + Number(jQuery("#order_shipping").val());
	var debits = Number(jQuery("#order_total_giftcards").val()) + Number(jQuery("#order_total_coupon").val()) + Number(jQuery("#order_total_discounts").val());
	var grand_total = totals - debits;
	
	//FORMAT THIS SET
	if(grand_total <= 0)
		jQuery("#order_grand_total").val("0.00");
	else
		jQuery("#order_grand_total").val(formatCurrency(grand_total));
	
}//end function updateGrandTotal



function updateSubTotal()
{
	var sub_total = 0;
	
	jQuery("input.product_total_price").each(function(){
		sub_total += Number(jQuery(this).val());
	});//end each
	
	//FORMAT THIS SET
	jQuery("#order_subtotal").val(formatCurrency(sub_total));
	
}//end function updateSubTotal



function updateGiftCards()
{
	var gc_total = 0;
	jQuery("input.gift_card_value").each(function(){
		gc_total += Number(jQuery(this).val());
	});//end each
	
	//FORMAT THIS SET
	jQuery("#order_total_giftcards").val(formatCurrency(gc_total));
	
}//end function


var free_shipping = false;
function updateCoupons()
{
	var dollar = 1;
	var percentage = 2;
	var shipping = 3;
	
	var coupon_total = 0;
	
	//if there is a coupon
	if(jQuery("#coupon_value").length > 0)
	{
		//if we meet the min purchase
		if( Number(jQuery("#order_subtotal").val()) >= Number(jQuery("#coupon_min_purchase").val()) )
		{
			var coup_type = Number(jQuery("#coupon_type").val());
			
			if(coup_type == dollar){
				
				coupon_total = Number(jQuery("#coupon_value").val());
				
			}else if(coup_type == percentage){
				
				coupon_total = Math.round((Number(jQuery("#coupon_value").val()) / 100) * (Number(jQuery("#order_subtotal").val()) * 100)) / 100;
				
			}else if(coup_type == shipping){
				
				free_shipping = true;
				jQuery("#order_shipping").val("0.00");
				
			}//end if-else
			
		}//end if
		
	}//end if
	
	//FORMAT THIS SET
	jQuery("#order_total_coupon").val(formatCurrency(coupon_total));
	
}//end function



function calculateTax()
{
	var KY = 18;
	var state;
	if(jQuery("#user_profile_type_id").val() == 1){
		state = Number(jQuery("#order_shipping_state_id").val());
	}else{
		state = Number(jQuery("#order_billing_state_id").val())
	}
	
	if( state == KY){
		
		var sub = Number(jQuery("#order_subtotal").val()) - Number(jQuery("#order_total_coupon").val());
		
		//FORMAT THIS SET
		jQuery("#order_tax").val(formatCurrency((sub * 0.06)));
		
	}//end if

	
}//end function



function calculateShipping(e)
{
	if(e != undefined)
		e.preventDefault();
	
	var sub = Number(jQuery("#order_subtotal").val()) - Number(jQuery("#order_total_coupon").val());
	var ship_state_id = jQuery("#shipping_state_id").val();
	
	jQuery.ajax({
	   type: "POST",
	   dataType: 'script',
	   url: "/admin/orders/calc_shipping",
	   data: "subtotal=" + sub + "&shipping_state_id=" + ship_state_id
	 });
	
}//end function


function _roundNumber(num,dec) {
	var snum=num.toString()+"000000000000000001";
	var sep=snum.indexOf(".");
	var beg=snum.substring(0,snum.indexOf("."));
	snum=snum.substring(eval(snum.indexOf(".")+1),snum.length);
	var dig=snum.substring(0,eval(dec-1));
	snum=snum.substring(eval(dec-1),dec);
	snum=parseInt(snum);
	gohigher=false;
	if (snum>4) {gohigher=true;}
	if (gohigher) {snum=parseInt(snum);snum++;}
	snum=snum.toString();
	//alert(beg+"."+dig+""+snum);
	num=beg+"."+dig+""+snum;
	return num;

}//end _roundNumber





function shippingAddressPicker()
{
	var val = jQuery(this).val();
	
	if(val == 1){	//bill & ship are same
		
		jQuery("#shipping_fieldset").hide();
		
	}else if(val == 2){ //bill & ship are different
		
		jQuery("#shipping_fieldset").show();
		jQuery("#shipping_fieldset legend").text("Shipping Address");
		jQuery("#shipping_address_2_field").show();
		jQuery("#dorm_shipping_address_2_field").hide();
		jQuery(".dormship").hide();
		
	}else if(val == 3){ //dorm shipping
		
		jQuery("#shipping_fieldset").show();
		jQuery("#shipping_fieldset legend").text("Dorm Shipping Information");
		jQuery(".dormship").show();
		jQuery("#shipping_address_2_field").hide();
		jQuery("#dorm_shipping_address_2_field").show();
		
	}//end else-if
	
}//end function shippingAddressPicker



function addCoupon(e)
{
	e.preventDefault();
	
	if(jQuery("#coupon_number").val() == "")
	{
		alert("Coupon number can't be blank!");
		return;
	}
	
	jQuery.ajax({
	   type: "POST",
	   dataType: 'script',
	   url: "/admin/orders/add_coupon_to_order",
	   data: "coupon_number=" + jQuery("#coupon_number").val(),
	 });
	
}//end function addCoupon



function addGiftCard(e)
{
	e.preventDefault();
	
	if(jQuery("#gift_card_number").val() == "" || jQuery("#gift_card_pin").val() == "")
	{
		alert("Gift Card number and pin are required");
		return;
	}
	
	jQuery.ajax({
	   type: "POST",
	   dataType: 'script',
	   url: "/admin/orders/add_gift_card_to_order",
	   data: "gift_card_number=" + jQuery("#gift_card_number").val() + "&gift_card_pin=" + jQuery("#gift_card_pin").val(),
	 });
	
}//end function addGiftCard


function removeDuplicateGiftCards()
{
	var val = jQuery("#gift_cards_holder .gift_card input[type='hidden']:last").val();
	var length = jQuery("#gift_cards_holder .gift_card input[type='hidden']").length - 1;
	
	for(var i=0; i < length; i++)
	{
		if(jQuery("#gift_cards_holder .gift_card input[type='hidden']").eq(i).val() == val)
		{
			alert("Duplicate Gift Card!");
			jQuery("#gift_cards_holder .gift_card").eq(i).remove();
		}
		
	}//end for
	
}//end function removeDuplicateGiftCards



function afterAutoComplete(e)
{
	if(jQuery(e).attr("name") == 'product_search_term')
	{
		jQuery.ajax({
		   type: "POST",
		   dataType: 'script',
		   url: "/admin/orders/product_staging",
		   data: "product_name=" + escape(jQuery(e).val()),
		 });
	
	}else if(jQuery(e).attr("name") == 'user_search_term'){
		
		jQuery.ajax({
		   type: "POST",
		   dataType: 'script',
		   url: "/admin/orders/set_user",
		   data: "email=" + jQuery(e).val(),
		 });
		
	}//end if else

}//end function 



function setupProductStaging()
{
	jQuery("#btn_add_to_order").unbind("click");
	jQuery("#btn_add_to_order").click(function(e){
		e.preventDefault();
		addProductToOrder();
	});//end click
	
}//end function



function addProductToOrder()
{

    //Serialize the data
    var data = jQuery('#product_stage').serializeAnything();

	jQuery.ajax({
	   type: "POST",
	   dataType: 'script',
	   url: "/admin/orders/insert_staged_product",
	   data: data
	 });
    
}//end function