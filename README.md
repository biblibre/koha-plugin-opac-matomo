# Koha plugin for Matamo JS code at OPAC

## Installation

1. Download KPZ file and install in your Koha
2. On Koha server, copy `config.yaml.sample` into `config.yaml`
3. Edit `config.yaml`
4. Enter your Matomo website in __tracker_url__
5. Enter the site id of this OPAC in __site_id__
6. Choose your language in lang (you may create a new __lang_xx.yaml__ file)

## Packaging

To create KPZ archive from git repository, run the following command:

``git archive --output=../koha-plugin.kpz --format=zip HEAD -- Koha``

## See also

* https://wiki.koha-community.org/wiki/Matomo
* https://matomo.org/home/

