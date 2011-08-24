// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery(document).ready(function() {

    jQuery("#toggleall").click(function() {
        var checked_status = this.checked;
        jQuery("input[type='checkbox']").each(function() {
            this.checked = checked_status;
        });
    });

    $('#header_source').dialog({
        autoOpen: false,
        width: 600
    });

    $('#show_header').click(function(){
        $('#header_source').dialog('open');
        return false;
    });

});

