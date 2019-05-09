package Koha::Plugin::Com::BibLibre::OpacMatomo;

use base qw(Koha::Plugins::Base);

use Modern::Perl;

use YAML qw(LoadFile);

use C4::Context;

our $VERSION = '1.0';

our $metadata = {
    name            => 'OpacMatomo',
    author          => 'BibLibre',
    description     => 'Matomo JS tracking code on OPAC',
    date_authored   => '2019-04-06',
    date_updated    => '2019-04-06',
    minimum_version => '18.1100000',
    maximum_version => undef,
    version         => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    my $self = $class->SUPER::new($args);

    return $self;
}

sub _get_conf {
    my ($self) = @_;

    my $conf;
    eval {
        my $conf_file_path = $self->mbf_path('config.yaml');
        $conf = LoadFile($conf_file_path);
    };
    if ($@) {
        warn "Error with config.yaml : $@";
        return;
    }

    return $conf;
}

sub _get_lang {
    my ($self) = @_;

    my $conf = $self->_get_conf;
    return unless $conf;

    my $l              = $conf->{'lang'};
    my $lang_file_path = $self->mbf_path("lang_$l.yaml");
    my $lang           = LoadFile($lang_file_path);

    return $lang;
}

sub opac_head {
    my ($self) = @_;

    my $conf = $self->_get_conf;
    return '' unless $conf;

    my $tracker_url = $conf->{'tracker_url'};

    my $ret = q|
<script src="__TRACKER_URL__/matomo.js"></script>
|;
    $ret =~ s/__TRACKER_URL__/$tracker_url/g;
    return $ret;
}

sub opac_js {
    my ($self) = @_;

    my $conf = $self->_get_conf;
    return '' unless $conf;
    my $tracker_url = $conf->{'tracker_url'};
    my $site_id     = $conf->{'site_id'};

    my $lang                     = $self->_get_lang;
    my $i18n_custom_var_dosortby = $lang->{'i18n_custom_var_dosortby'};
    my $i18n_custom_var_q        = $lang->{'i18n_custom_var_q'};
    my $i18n_custom_var_idx      = $lang->{'i18n_custom_var_idx'};
    my $i18n_custom_var_limit    = $lang->{'i18n_custom_var_limit'};
    my $i18n_custom_var_total    = $lang->{'i18n_custom_var_total'};
    my $i18n_custom_var_offset   = $lang->{'i18n_custom_var_offset'};

    my $ret = q|
<script type="text/javascript">

// Dont show if fails
try {

var piwikTracker = Piwik.getTracker( "__TRACKER_URL__/matomo.php", '__SITE_ID__' );
var url = window.location.href;
var uri = url;

// Number of resuluts after search
var total = $("#numresults > strong").text().replace(/[\D\.]+/g, "");
if ( ! total ) {
    total = "0"
}

var title = document.title;
// translate url encoding ("%2C" to "," ; %3A" to ":" ...) except for & and = (which are used in functions)
var regexurif26 = /%26/g ;
uri = uri.replace ( regexurif26 , '#26#' ) ;
var regexurif3D = /%3D/g ;
uri = uri.replace ( regexurif3D , '#3D#' ) ;
uri = decodeURIComponent ( uri ) ;
var regexurit26 = /#26#/g ;
uri = uri.replace ( regexurit26 , '%26' ) ;
var regexurit3D = /#3D#/g ;
uri = uri.replace ( regexurit3D , '%3D' ) ;
// setDocumentTitle
var regextitle = /^(.+) › (.+)$/ ;
title = title.replace( regextitle , '$2' ) ;//to keep only what is after " › "
piwikTracker.setDocumentTitle(title) ;

// Search results custom vars
if ( uri.match ( new RegExp ( "/cgi-bin/koha/opac-search.pl." ) ) ) {
    // to ensure that the first parameter is properly treated
    uri = uri.replace ( 'opac-search.pl?' , 'opac-search.pl?&' ) ;
    // preprocessing for "idx" : remove from url idx parameters wich are not befor a "q" parameter ; remove ",wrdl"
    var regexidxok = /&idx=([^&]+)&q=/g ;
    uri = uri.replace ( regexidxok , '&#idx#=$1&q=' ) ;
    var regexidxbad = /&idx=[^&]+/g ;
    uri = uri.replace ( regexidxbad , '' ) ;
    var regexidxfin = /&#idx#=/g ;
    uri = uri.replace ( regexidxfin , '&idx=' ) ;
    var regexidxwrdl = /&idx=([^&]+),wrdl/g ;
    uri = uri.replace ( regexidxwrdl , '&idx=$1' ) ;
    // preprocessing for "limit" : limit-yr becomes a "limit=yr:value" parameter ; replace ",????:" with ":"
    var regexlimityr = /&limit-yr=/g ;
    uri = uri.replace ( regexlimityr , '&limit=yr:' ) ;
    var regexlimit = /&limit=([^,]+),[^:]+:/g ;
    uri = uri.replace ( regexlimit , '&limit=$1:' ) ;
    // setCustomVariable
    // initialization of custom vars titles
    var customvartitle_dosortby = "__I18N_CUSTOM_VAR_DOSORTBY__" ;
    var customvartitle_q = "__I18N_CUSTOM_VAR_Q__" ;
    var customvartitle_idx = "__I18N_CUSTOM_VAR_IDX__" ;
    var customvartitle_limit = "__I18N_CUSTOM_VAR_LIMIT__" ;
    var customvartitle_total = "__I18N_CUSTOM_VAR_TOTAL__" ;
    var customvartitle_offset = "__I18N_CUSTOM_VAR_OFFSET__" ;
    // offset
    if ( geturiparam ( uri , "offset" ) ) { var customvarvalue_offset = geturiparam ( uri , "offset" , "" , "" , 1 ) ; }
    else {
        // total
        var customvarvalue_total = total ;
        // dosortby
        var customvarvalue_dosortby = "simple" ;
        if ( geturiparam ( uri , "do" ) ) { customvarvalue_dosortby = "advanced" ; }
        if ( geturiparam ( uri , "sort_by" ) ) { customvarvalue_dosortby = customvarvalue_dosortby + "," + geturiparam ( uri , "sort_by" ) ; }
        // q
        if ( geturiparam ( uri , "q" ) ) { var customvarvalue_q = geturiparam ( uri , "q" , ", " , " " , 1 ) ; }
        // idx
        if ( geturiparam ( uri , "idx" ) ) { var customvarvalue_idx = geturiparam ( uri , "idx" , "," , "" , 1 ) ; }
        else { var customvarvalue_idx = "kw" ; }
        // limit
        if ( geturiparam ( uri , "limit" ) ) { var customvarvalue_limit = geturiparam ( uri , "limit" , "," , "" , 1 ) ; }
    }
    //if offset, only the 2nd CustomVariable is set
    if ( customvarvalue_offset && customvarvalue_offset != 0 ) {
        piwikTracker.setCustomVariable ( 2 , customvartitle_offset , customvarvalue_offset , "page" ) ;
    } else {
    if ( customvarvalue_total ) { piwikTracker.setCustomVariable ( 1 , customvartitle_total , customvarvalue_total , "page" ) ; }
    if ( customvarvalue_dosortby ) { piwikTracker.setCustomVariable ( 2 , customvartitle_dosortby , customvarvalue_dosortby , "page" ) ; }
    if ( customvarvalue_q ) { piwikTracker.setCustomVariable ( 3 , customvartitle_q , customvarvalue_q , "page" ) ; }
    if ( customvarvalue_idx ) { piwikTracker.setCustomVariable ( 4 , customvartitle_idx , customvarvalue_idx , "page" ) ; }
    if ( customvarvalue_limit ) { piwikTracker.setCustomVariable ( 5 , customvartitle_limit , customvarvalue_limit , "page" ) ; } }
    uri = uri.replace( 'opac-search.pl?&' , 'opac-search.pl?' ) ;
}

var regexegal = /=/g;
url = url.replace ( regexegal , '[]=' ) ;// to replace = with []= into url, without this, multiple sames parameters aren't process by piwik
var regexcgibin = /\/cgi-bin\/koha\/([^\?]*)?/ ;
url = url.replace ( regexcgibin , '/$1' ) ;// to remove /cgi-bin/koha/ from url
piwikTracker.setCustomUrl ( url ) ;
piwikTracker.trackPageView () ;
piwikTracker.enableLinkTracking () ;

} catch ( err ) {}

// returns a string containing the list of values corresponding to one url's parameter
// uri = the url to parse , param = parameter to process , sep = separator between each value , rep = which replaces the sep, sorting = 1 to sort results
function geturiparam ( uri, param, sep, rep, sorting ) {
    // split on &, to have each argument in a row of an array
    var tab = uri.substring ( 1 ).split ( '&' ) ; var tabparam = [];
    // then parse each argument, split on = to separate key and value
    for ( var i = 0 ; i < tab.length ; i++ ) {
        var x = tab [ i ].split ( '=' ) ;
        if ( x [ 0 ] == param ) {
            var xvalue = "" ;
            // warning = there's probably something wrong in Koha, because the value sometimes contains a =
            // so the split sometimes don't result in a size 2 array
            // so rebuild everything after the [0] -the key- as the value
            for ( var ix = 1 ; ix < x.length ; ix++ ) { if ( ix == 1 ) { xvalue = x [ ix ] } else { xvalue = xvalue + "=" + x [ ix ] } }
            if ( sep && rep ) { var regexrep = new RegExp ( trim ( sep ) , 'g' ) ; xvalue = xvalue.replace ( regexrep , rep ) ; }
            tabparam.push ( xvalue ) ; } }
    if ( sorting == 1 ) { tabparam.sort () ; }
    if ( sep ) { var out = tabparam.join ( sep ) ; } else { var out = tabparam.join ( "" ) ; }
    return out ;
}

// Remove trailling and leading spaces
function trim ( myString ) { return myString.replace ( /^\s+/g , '' ).replace (/\s+$/g , '' ) }

</script>
|;
    $ret =~ s/__TRACKER_URL__/$tracker_url/g;
    $ret =~ s/__SITE_ID__/$site_id/g;
    $ret =~ s/__I18N_CUSTOM_VAR_DOSORTBY__/$i18n_custom_var_dosortby/g;
    $ret =~ s/__I18N_CUSTOM_VAR_Q__/$i18n_custom_var_q/g;
    $ret =~ s/__I18N_CUSTOM_VAR_IDX__/$i18n_custom_var_idx/g;
    $ret =~ s/__I18N_CUSTOM_VAR_LIMIT__/$i18n_custom_var_limit/g;
    $ret =~ s/__I18N_CUSTOM_VAR_TOTAL__/$i18n_custom_var_total/g;
    $ret =~ s/__I18N_CUSTOM_VAR_OFFSET__/$i18n_custom_var_offset/g;

    return $ret;
}

1;
