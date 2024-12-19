require 'pagy/extras/i18n'
require 'pagy/extras/overflow'
require 'pagy/extras/pagy'

Pagy::DEFAULT[:items] = 10
Pagy::DEFAULT[:overflow] = :last_page
