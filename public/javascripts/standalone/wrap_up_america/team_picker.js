var none = new Array("No Teams Available");
var louisville = new Array("Alpha Omicron Pi","Chi Omega","Delta Zeta","Kappa Delta","Pi Beta Phi","Sigma Kappa","ROTC","UofL Athletics");
var toledo = new Array("General Community Donations", "Alpha Sigma Phi", "Kappa Delta Rho", "Phi Gamma Delta", "Phi Kappa Psi", "Pi Kappa Alpha", "Pi Kappa Phi", "Sigma Alpha Epsilon", "Sigma Phi Epsilon", "Theta Chi", "Theta Tau", "Triangle", "Alpha Xi Delta", "Alpha Omicron Pi", "Alpha Chi Omega", "Delta Delta Delta", "Chi Omega", "Kappa Delta", "Pi Beta Phi", "CAP", "Alpha Phi Omega", "College Republicans", "Gesu Underground");
var pitt = new Array("Sigma Chi","Kappa Delta","Delta Zeta","Chi Omega","Tri Delta","Tri Sigma","Kappa Kappa Gamma","Alpha Delta Pi");
var michigan = new Array("Alpha Chi Omega", "Alpha Epsilon Phi", "Zeta Tau Alpha", "Phi Rho Alpha", "Sigma Chi Fraternity");

$(document).ready(function() {
	$('select.campus_selector').eq(0).change(function() {

		var team;
		if($('select.campus_selector').eq(0).children('option:selected').text().match(/Louisville/i)) {
			team = louisville;
		} else if($('select.campus_selector').eq(0).children('option:selected').text().match(/Toledo/i)) {
			team = toledo;
		} else if($('select.campus_selector').eq(0).children('option:selected').text().match(/Pittsburgh/i)) {
			team = pitt;
		} else if($('select.campus_selector').eq(0).children('option:selected').text().match(/Michigan/i)) {
			team = michigan;
		} else {
			team = none;
		}
		var option_html = '';
		for(var i = 0; i < team.length; i++) {
			option_html += "<option value='" + team[i] + "'>" + team[i] + "</option>";
		}
		$('#team').html(option_html);
	});
});